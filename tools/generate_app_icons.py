import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def lerp_color(c1: tuple[int, int, int], c2: tuple[int, int, int], t: float) -> tuple[int, int, int]:
    return (lerp(c1[0], c2[0], t), lerp(c1[1], c2[1], t), lerp(c1[2], c2[2], t))


def radial_gradient(size: int, inner: tuple[int, int, int], outer: tuple[int, int, int]) -> Image.Image:
    img = Image.new("RGB", (size, size), outer)
    px = img.load()
    cx = cy = (size - 1) / 2
    max_d = math.hypot(cx, cy)
    for y in range(size):
        for x in range(size):
            d = math.hypot(x - cx, y - cy) / max_d
            t = min(1.0, max(0.0, d))
            px[x, y] = lerp_color(inner, outer, t)
    return img


def draw_paw(img: Image.Image, size: int, pad: float) -> None:
    draw = ImageDraw.Draw(img)
    primary = (249, 115, 22)
    secondary = (251, 146, 60)
    dark = (154, 52, 18)
    cream = (255, 247, 237)

    s = size
    cx = s / 2
    cy = s / 2 + s * 0.04
    r = s * (0.20 - pad * 0.12)

    toe_r = r * 0.42
    toe_y = cy - r * 1.12
    toes = [
        (cx - r * 1.10, toe_y, toe_r, primary),
        (cx + r * 1.10, toe_y, toe_r, primary),
        (cx - r * 0.36, toe_y - r * 0.44, toe_r, secondary),
        (cx + r * 0.36, toe_y - r * 0.44, toe_r, secondary),
    ]

    outline_w = max(2, int(s * 0.028))
    for (tx, ty, tr, col) in toes:
        draw.ellipse([tx - tr, ty - tr, tx + tr, ty + tr], fill=col, outline=dark, width=outline_w)

    pad_rx = r * 1.45
    pad_ry = r * 1.15
    pad_box = [cx - pad_rx, cy - pad_ry, cx + pad_rx, cy + pad_ry]
    draw.rounded_rectangle(pad_box, radius=pad_ry * 0.55, fill=dark, outline=dark, width=outline_w)
    inset = outline_w * 1.4
    pad_box2 = [pad_box[0] + inset, pad_box[1] + inset, pad_box[2] - inset, pad_box[3] - inset]
    draw.rounded_rectangle(pad_box2, radius=pad_ry * 0.52, fill=dark)

    shine = Image.new("RGBA", (s, s), (0, 0, 0, 0))
    sd = ImageDraw.Draw(shine)
    sd.ellipse(
        [
            cx - pad_rx * 0.85,
            cy - pad_ry * 0.75,
            cx + pad_rx * 0.55,
            cy - pad_ry * 0.05,
        ],
        fill=(cream[0], cream[1], cream[2], 140),
    )
    shine = shine.filter(ImageFilter.GaussianBlur(radius=s * 0.02))
    img.alpha_composite(shine)


def make_icon(size: int, pad: float) -> Image.Image:
    bg_inner = (255, 247, 237)
    bg_outer = (249, 115, 22)
    base = radial_gradient(size, bg_inner, bg_outer).convert("RGBA")

    vignette = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    vd.ellipse(
        [
            size * 0.05,
            size * 0.05,
            size * 0.95,
            size * 0.95,
        ],
        outline=(154, 52, 18, 80),
        width=max(2, int(size * 0.02)),
    )
    vignette = vignette.filter(ImageFilter.GaussianBlur(radius=size * 0.01))
    base.alpha_composite(vignette)

    mark = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw_paw(mark, size, pad)
    base.alpha_composite(mark)

    return base


def save_resized(src: Image.Image, out_path: Path, size: int) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    img = src.resize((size, size), resample=Image.Resampling.LANCZOS)
    img.save(out_path, format="PNG", optimize=True)


def main() -> None:
    root = Path(__file__).resolve().parents[1]

    ios_set = root / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    android_res = root / "android" / "app" / "src" / "main" / "res"
    web_icons = root / "web" / "icons"
    web_favicon = root / "web" / "favicon.png"
    macos_set = root / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    app_assets = root / "assets" / "images"

    base_1024 = make_icon(1024, pad=0.12)
    maskable_1024 = make_icon(1024, pad=0.22)

    ios_map = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }

    for name, px in ios_map.items():
        save_resized(base_1024, ios_set / name, px)

    android_map = {
        "mipmap-mdpi/ic_launcher.png": 48,
        "mipmap-hdpi/ic_launcher.png": 72,
        "mipmap-xhdpi/ic_launcher.png": 96,
        "mipmap-xxhdpi/ic_launcher.png": 144,
        "mipmap-xxxhdpi/ic_launcher.png": 192,
    }
    for rel, px in android_map.items():
        save_resized(base_1024, android_res / rel, px)

    save_resized(base_1024, web_icons / "Icon-192.png", 192)
    save_resized(base_1024, web_icons / "Icon-512.png", 512)
    save_resized(maskable_1024, web_icons / "Icon-maskable-192.png", 192)
    save_resized(maskable_1024, web_icons / "Icon-maskable-512.png", 512)
    save_resized(base_1024, web_favicon, 48)

    macos_sizes = [16, 32, 64, 128, 256, 512, 1024]
    for s in macos_sizes:
        save_resized(base_1024, macos_set / f"app_icon_{s}.png", s)

    app_assets.mkdir(parents=True, exist_ok=True)
    save_resized(base_1024, app_assets / "app_icon_512.png", 512)

    print("done")


if __name__ == "__main__":
    main()
