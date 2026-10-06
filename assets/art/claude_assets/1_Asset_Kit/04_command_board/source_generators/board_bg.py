"""Fort Knocks – Command Board background: vertically seamless tile (planks + pinned map).
Everything is generated with wrap-around in Y, so the tile repeats with no seam.
Usage: python3 board_bg.py out_prefix [seed]
Writes out_prefix_a/b/c.png (chained: a->b->c->a join seamlessly) and out_prefix_planks.png.
"""
import sys, numpy as np
from PIL import Image, ImageDraw, ImageFilter

TILE, N = 2160, 3
W, H = 1080, TILE * N
rng = np.random.default_rng(int(sys.argv[2]) if len(sys.argv) > 2 else 7)

def pnoise(h, w, scale_y, scale_x, octaves=4, seed=0):
    """Periodic (tileable both ways) fractal noise via FFT-filtered white noise, 0..1."""
    r = np.random.default_rng(seed)
    out = np.zeros((h, w))
    amp = 1.0
    for o in range(octaves):
        n = r.normal(size=(h, w))
        # scale = approximate feature size in pixels (bigger = smoother)
        fy = np.fft.fftfreq(h)[:, None] * max(scale_y / 2 ** o, 1) * 3
        fx = np.fft.fftfreq(w)[None, :] * max(scale_x / 2 ** o, 1) * 3
        filt = np.exp(-(fx ** 2 + fy ** 2))
        layer = np.real(np.fft.ifft2(np.fft.fft2(n) * filt))
        layer = (layer - layer.mean()) / (layer.std() + 1e-9)
        out += layer * amp
        amp *= 0.5
    out = (out - out.min()) / (out.max() - out.min())
    return out

def periodic(y, terms):
    """sum of sines with integer periods (per TILE height, scaled to the full strip) -> seamless in y"""
    return sum(a * np.sin(2 * np.pi * (k * N * y / H) + p) for a, k, p in terms)

def rgb(h):
    h = h.lstrip('#'); return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], float)

# ---------------------------------------------------------------- planks
img = np.zeros((H, W, 3))
x = 0
grain = pnoise(H, W, 260, 6, 4, 1)            # long vertical streaks
blot = pnoise(H, W, 300, 300, 3, 2)
while x < W:
    pw = int(rng.integers(130, 190))
    base = rgb('#5b3a22') * rng.uniform(0.82, 1.12)
    sl = slice(x, min(x + pw, W))
    g = grain[:, sl]
    col = base[None, None, :] * (0.62 + 0.7 * g[..., None]) * (0.85 + 0.3 * blot[:, sl][..., None])
    img[:, sl] = col
    img[:, max(x - 3, 0):x + 3] = rgb('#1c110a')   # gap
    x += pw
img = np.clip(img, 0, 255)
planks_only = img.copy()

# ---------------------------------------------------------------- map strip with torn edges
yy = np.arange(H)
left = 104 + periodic(yy, [(26, 3, .3), (12, 7, 1.2), (6, 23, 2.1), (3, 61, .7), (2, 113, 1.9)])
right = W - 104 + periodic(yy, [(24, 4, 2.2), (14, 9, .4), (6, 27, 1.7), (3, 67, 2.9), (2, 109, .4)])
xx = np.arange(W)[None, :]
mask = ((xx > left[:, None]) & (xx < right[:, None])).astype(float)
# shadow of the map on the planks
sh = Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(14))
sh = np.roll(np.asarray(sh, float) / 255, (10, 8), (0, 1))
img *= (1 - 0.55 * sh[..., None])

paper_n = pnoise(H, W, 420, 420, 4, 3)
fine = pnoise(H, W, 6, 6, 2, 4)
grime = pnoise(H, W, 160, 160, 4, 13)
paper = rgb('#d3c4a4')[None, None] * (0.84 + 0.26 * paper_n[..., None]) * (0.94 + 0.10 * fine[..., None])
paper *= (1 - 0.22 * np.clip((grime - 0.6) * 3, 0, 1))[..., None]

# coloured map regions (green land, rust patches) with irregular boundaries
land = 0.8 * pnoise(H, W, 260, 220, 3, 5) + 0.2 * pnoise(H, W, 26, 26, 2, 15)
edge_bias = np.clip(1 - (np.minimum(xx - left[:, None], right[:, None] - xx) / 260), 0, 1)
green = ((land + 0.35 * edge_bias) > 0.86).astype(float)
gb = np.asarray(Image.fromarray((green * 255).astype(np.uint8)).filter(ImageFilter.FIND_EDGES).filter(ImageFilter.MaxFilter(3)), float) / 255
green = np.asarray(Image.fromarray((green * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(2)), float) / 255
gcol = rgb('#6d7a45')[None, None] * (0.8 + 0.4 * pnoise(H, W, 40, 40, 3, 6)[..., None])
paper = paper * (1 - green[..., None]) + gcol * green[..., None]
paper = paper * (1 - 0.7 * gb[..., None]) + rgb('#3d3a22')[None, None] * 0.7 * gb[..., None]
rust = 0.8 * pnoise(H, W, 220, 220, 3, 8) + 0.2 * pnoise(H, W, 24, 24, 2, 18)
rmask = np.clip((rust + 0.25 * edge_bias - 0.80) * 10, 0, 1) * (1 - green)
paper = paper * (1 - 0.75 * rmask[..., None]) + rgb('#7d3f22')[None, None] * 0.75 * rmask[..., None]
img = img * (1 - mask[..., None]) + paper * mask[..., None]

# ---------------------------------------------------------------- line work (drawn with Y wrap)
lay = Image.new('RGBA', (W, H * 3), (0, 0, 0, 0))
d = ImageDraw.Draw(lay)
def wrap_line(pts, fill, width):
    for off in (0, H, 2 * H):
        d.line([(px, py + off) for px, py in pts], fill=fill, width=width, joint='curve')
# grid
for gx in range(120, W, 120):
    wrap_line([(gx, -10), (gx, H + 10)], (90, 70, 50, 55), 2)
for gy in range(0, H, 120):
    wrap_line([(0, gy), (W, gy)], (90, 70, 50, 55), 2)
# fold creases
for fy in range(0, H, TILE // 2):
    wrap_line([(0, fy + 60), (W, fy + 60)], (255, 245, 220, 70), 5)
    wrap_line([(0, fy + 64), (W, fy + 64)], (60, 45, 30, 60), 2)
wrap_line([(540, -10), (540, H + 10)], (255, 245, 220, 60), 5)
# roads: smooth periodic curves
for k in range(2):
    x0 = rng.uniform(250, 830)
    terms = [(rng.uniform(80, 200), rng.integers(1, 3), rng.uniform(0, 6)), (rng.uniform(20, 60), rng.integers(3, 6), rng.uniform(0, 6))]
    ys = np.linspace(0, H, 400)
    pts = list(zip(np.clip(x0 + periodic(ys, terms), 40, W - 40), ys))
    wrap_line(pts, (92, 72, 50, 170), 7)
    wrap_line(pts, (214, 200, 172, 220), 3)
for k in range(26 * N):    # short branching roads
    y0 = rng.uniform(0, H); x0 = rng.uniform(100, 500)
    pts = [(x0, y0)]
    for j in range(int(rng.integers(2, 5))):
        px, py = pts[-1]; pts.append((px + rng.uniform(60, 160), py + rng.uniform(-90, 90)))
    wrap_line(pts, (84, 64, 44, 150), 3)
# faded stamp boxes
for k in range(5 * N):
    sx, sy = rng.uniform(160, 820), rng.uniform(0, H)
    for off in (0, H, 2 * H):
        d.rounded_rectangle([sx, sy + off, sx + 150, sy + off + 44], 6, outline=(70, 55, 40, 80), width=3)
        for j in range(4):
            d.line([(sx + 16 + j * 32, sy + off + 22), (sx + 34 + j * 32, sy + off + 22)], fill=(70, 55, 40, 70), width=6)
lay = lay.crop((0, H, W, 2 * H))
la = np.asarray(lay, float) / 255
a = la[..., 3:4] * mask[..., None]
img = img * (1 - a) + la[..., :3] * 255 * a

# torn edge highlight (paper thickness) + darkening near edges
dist = np.minimum(xx - left[:, None], right[:, None] - xx)
rim = np.clip(1 - np.abs(dist - 3) / 3, 0, 1) * mask
img = img * (1 - 0.6 * rim[..., None]) + rgb('#efe3c8')[None, None] * 0.6 * rim[..., None]
edge_dark = np.clip(1 - dist / 70, 0, 1) * mask
img *= (1 - 0.25 * edge_dark[..., None])

# overall painterly grain
img *= (0.94 + 0.12 * pnoise(H, W, 3, 3, 1, 9)[..., None])
out = Image.fromarray(np.clip(img, 0, 255).astype(np.uint8))
out = out.filter(ImageFilter.UnsharpMask(2, 40, 2))
pre = sys.argv[1]
for i in range(N):
    out.crop((0, i * TILE, W, (i + 1) * TILE)).save(f'{pre}_{"abc"[i]}.png', optimize=True)
Image.fromarray(np.clip(planks_only[:TILE], 0, 255).astype(np.uint8)).save(f'{pre}_planks.png', optimize=True)
print('saved', N, 'tiles + planks')
