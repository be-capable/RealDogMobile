import math
from pathlib import Path

from PIL import Image, ImageDraw


def make_frame(i: int, n: int, size: int) -> Image.Image:
    t = i / n
    bg = (255, 247, 237)
    img = Image.new("RGBA", (size, size), bg)
    draw = ImageDraw.Draw(img)

    cx = size // 2
    cy = size // 2 + 4
    r = int(size * 0.18)

    dx = int(math.sin(t * math.tau) * (size * 0.03))
    tail_w = int(size * 0.10)
    tail_h = int(size * 0.04)

    body = (249, 115, 22)
    body2 = (251, 146, 60)
    dark = (154, 52, 18)

    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=body, outline=dark, width=max(2, size // 32))
    ear = [
        (cx - int(r * 0.9), cy - int(r * 0.7)),
        (cx - int(r * 1.2), cy - int(r * 1.4)),
        (cx - int(r * 0.3), cy - int(r * 1.1)),
    ]
    draw.polygon(ear, fill=body2, outline=dark)

    tail_x = cx + r - int(size * 0.02)
    tail_y = cy + int(r * 0.1)
    draw.rounded_rectangle(
        [tail_x, tail_y, tail_x + tail_w, tail_y + tail_h],
        radius=tail_h // 2,
        fill=body2,
        outline=dark,
        width=max(2, size // 36),
    )
    draw.rounded_rectangle(
        [tail_x + dx, tail_y - dx // 2, tail_x + tail_w + dx, tail_y + tail_h - dx // 2],
        radius=tail_h // 2,
        fill=body,
        outline=dark,
        width=max(2, size // 36),
    )

    eye_r = max(2, size // 48)
    draw.ellipse([cx - int(r * 0.35) - eye_r, cy - int(r * 0.2) - eye_r, cx - int(r * 0.35) + eye_r, cy - int(r * 0.2) + eye_r], fill=dark)
    draw.ellipse([cx + int(r * 0.10) - eye_r, cy - int(r * 0.2) - eye_r, cx + int(r * 0.10) + eye_r, cy - int(r * 0.2) + eye_r], fill=dark)

    nose_r = max(2, size // 44)
    draw.ellipse([cx + int(r * 0.02) - nose_r, cy + int(r * 0.10) - nose_r, cx + int(r * 0.02) + nose_r, cy + int(r * 0.10) + nose_r], fill=dark)

    return img.convert("P", palette=Image.Palette.ADAPTIVE, colors=64)


def main() -> None:
    out_dir = Path(__file__).resolve().parents[1] / "assets" / "gifs"
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / "dog_wag_128.gif"

    n = 16
    size = 128
    frames = [make_frame(i, n, size) for i in range(n)]
    frames[0].save(
        out_path,
        save_all=True,
        append_images=frames[1:],
        duration=60,
        loop=0,
        optimize=True,
        disposal=2,
    )

    print(out_path)


if __name__ == "__main__":
    main()

