# ไพรนิทรา · Bedtime Relax Music

A bedtime web app that plays calm music with nature sounds, matched to how stressed you feel tonight (levels 1–10). Each track plays for 3 minutes and the playlist cycles until you stop it or the sleep timer fades it out.

- 15 generated tracks (music and nature sounds are synthesized live in the browser with the Web Audio API), each with an animated night scene
- Upload your own songs and pictures; they alternate with the built-in tracks
- Breathing ring (4-6, 4-4-6, 4-7-8), sleep timer, ±10 s seeking
- Sleep history: stress level, start time and minutes listened per night
- Optional sign-in by email link to keep your files and history in Supabase and use them on any device

## Files

| File | What it is |
| --- | --- |
| `index.html` | The whole app |
| `config.js` | Supabase URL and publishable key (leave empty to run without cloud sync) |
| `supabase/setup.sql` | Tables, row-level security and the private `media` storage bucket |

## Supabase setup

1. Run `supabase/setup.sql` in the SQL editor (already applied to project `orldpdisplmplxrrqaan`).
2. **Authentication → URL Configuration**: set **Site URL** to the GitHub Pages address, e.g. `https://onworkjobs-a11y.github.io/Bedtime-relax-music/`, and add the same URL under **Redirect URLs**. Without this the sign-in link sends people to `localhost`.
3. Put the project URL and publishable key in `config.js`.

Each user can only read and change their own rows and files (`<user id>/…` in the `media` bucket). Files up to 50 MB.

## GitHub Pages

Settings → Pages → Build and deployment → Source: **Deploy from a branch**, Branch: **main**, folder **/ (root)**.
