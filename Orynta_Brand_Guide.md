# ORYNTA — Brand Guide
**Grow smarter, farm better**

---

## 1. Brand Foundation

**Name:** Orynta — short, easy to say across English and French speakers, no baggage from an existing word, easy to trademark-check locally.

**Mission:** Put real, localized agronomic intelligence into every Cameroonian smallholder farmer's hand — on the phone they already own, in the language they already speak, with or without a data connection.

**Personality:** Grounded, capable, plain-spoken, quietly confident. Orynta talks like a trusted local extension officer, not a tech startup. It never oversells — it shows its confidence level and admits when it's not sure.

**Brand promise:** Real answers, at the moment you need them, without needing a lab.

### 1.1 Voice & Tone
- **Plain over clever.** Farmers are the audience, not investors — even investor-facing material should stay legible to a non-specialist.
- **Confident, never absolute.** Always show or imply certainty level ("likely," "high confidence," "we're not sure — here's who can help").
- **Respectful, never condescending.** Low literacy or limited smartphone experience is a design constraint, not a reason to talk down.
- **Action-first.** Every piece of information ends in something the farmer can *do* ("spray by Thursday," not just "rain is coming").

**Sample lines:**
- App result: *"Likely late blight — 82% confidence. Here's what to do next."*
- Low-confidence case: *"We're not fully sure. An agronomist will review your photo and get back to you."*
- Weather advisory: *"Good window to plant maize this week. Heavy rain expected from Monday."*

**Avoid:** hype words ("revolutionary," "game-changing"), technical jargon in farmer-facing copy (save "NPK," "confidence interval," etc. for the web portal / pitch materials), and false certainty.

---

## 2. Logo Concept

**Primary mark:** a seedling/sprout form (two-leaf silhouette) — already used across pitch materials — paired with the wordmark "ORYNTA" in a confident serif.

**Construction notes:**
- The sprout mark should work at small sizes (app icon, favicon) as a solid single-color shape — no fine detail that disappears below ~32px.
- Keep clear space around the mark equal to the height of the sprout on all sides.
- Wordmark is always set in title case or full caps — never lowercase "orynta" as a standalone lockup (readability at small sizes in French/English mixed contexts).

**Lockups:**
- Horizontal: sprout + wordmark side by side (primary, for headers/web).
- Stacked: sprout above wordmark (app icon, social avatars).
- Mark-only: sprout alone, for app icon / favicon / watermark contexts, once brand recognition is established.

**Don't:**
- Don't recolor the sprout outside the approved palette.
- Don't add drop shadows, gradients, or 3D effects to the mark.
- Don't stretch or skew the lockup.

---

## 3. Color Palette

Primary theme: **Forest & Moss** — chosen because it reads as agriculture without defaulting to a cliché bright green, and holds up in both a dark "premium" mode and a light "practical" mode.

| Role | Name | Hex | Usage |
|---|---|---|---|
| Primary | Forest | `#2C5F2D` | Primary buttons, headers, brand mark |
| Primary Dark | Forest Dark | `#1B3D1C` | Dark backgrounds (title/closing screens, nav bars) |
| Secondary | Moss | `#97BC62` | Accents, secondary buttons, success states, icon fills on dark |
| Neutral Light | Cream | `#F7F6F1` | Card backgrounds, light-mode surface (not a beige/tan default — kept close to white) |
| Accent | Amber | `#C97A2B` | Alerts, highlights, "action needed" states, kickers/labels — use sparingly, never as a dominant color |
| Ink | `#222A1F` | Primary text on light backgrounds |
| Grey | `#6B7568` | Secondary/muted text, captions |
| White | `#FFFFFF` | Text on dark backgrounds, base light surface |

**Confidence-band colors (functional, app-specific — not brand accents, keep consistent everywhere they appear):**
| Level | Color | Hex |
|---|---|---|
| High confidence | Moss green | `#4C8C3B` |
| Medium confidence | Amber | `#C97A2B` |
| Low confidence / needs review | Muted red-orange | `#B4462E` |

**Usage rule:** one color dominates any given screen (60–70% Forest or Cream depending on light/dark mode), Moss and Amber are supporting/accent only. Never give all colors equal visual weight. Do not default to generic blue anywhere in the product.

---

## 4. Typography

| Use | Typeface | Notes |
|---|---|---|
| Headlines / brand moments | Cambria (or a similar serif available cross-platform) | Used for titles, pitch materials, marketing — gives warmth and trust, avoids a cold "generic tech" feel |
| App UI / body text | System default (Roboto on Android, San Francisco on iOS) or **Calibri/Inter** for cross-platform docs | Prioritize legibility and fast rendering on low-end devices over brand personality in-app |
| Documents (SRS, pitch decks, reports) | Cambria (headers) + Calibri (body) | Matches existing pitch deck and document styling already produced |

**Sizing (app):**
- Screen title: 20–24pt bold
- Section header: 16–18pt bold
- Body text: 14–16pt (never smaller — low-vision and low-literacy users need headroom)
- Captions/meta: 11–12pt, muted grey

**Sizing (documents/decks):** Titles 32–44pt bold · Section headers 20–24pt bold · Body 14–16pt · Captions 10–12pt muted — consistent with the SRS/exec summary/pitch deck already produced.

---

## 5. Iconography & Imagery

- **Icon style:** simple, solid-fill, rounded — no thin-line/outline icons (poor visibility on low-end, low-brightness screens outdoors in daylight).
- **Icon placement:** icons live inside a solid-color circle (Forest or Amber fill, white/cream icon) — this is the app's one consistent visual motif; repeat it everywhere rather than introducing new decorative devices.
- **Photography:** where real photography is used (marketing, video, web), favor real Cameroonian farms, crops, and people over stock imagery that reads as generic or non-African. Avoid imagery that could reinforce a "poverty tourism" framing — show competence and agency, not just hardship.
- **Illustration:** if custom illustration is used for onboarding, keep it flat, warm, and grounded — no cartoonish exaggeration.

**Never use:**
- Generic laptop/hologram/circuit-board "tech" imagery — Orynta is a farming tool, not a generic SaaS product.
- Decorative accent stripes, color bars, or edge borders on cards — use a subtle background tint or soft shadow instead if a card needs to stand out.

---

## 6. UI Component Patterns

- **Cards:** rounded corners (~8px radius), soft drop shadow (`blur ~8px, low opacity`), never a hard border or edge accent stripe.
- **Buttons:** solid Forest fill for primary actions, Cream/white with Forest text for secondary, Amber reserved for "needs attention" actions (e.g. "Review escalated case").
- **Confidence badges:** always visible, always color-coded per §3, always paired with a plain-language label ("High confidence" not just a color).
- **Navigation:** icon-first bottom nav (max 4–5 items) for the farmer app — Scan / Home / Market / Profile as the core set `[confirm final IA with design]`.
- **Empty/offline states:** always explain *why* (e.g. "No connection — showing your last saved advisory") rather than showing a blank screen or generic error.
- **Language switcher:** always accessible from the home screen, not buried in settings — this is a core accessibility commitment, not a nice-to-have.

---

## 7. Application Across Touchpoints

| Touchpoint | Key brand notes |
|---|---|
| Mobile app | Cream/light mode by default (outdoor daylight legibility); Forest Dark only for onboarding/splash |
| Web portal | Lighter, more information-dense than the farmer app — same palette, tighter type scale, data-table friendly |
| Pitch deck | Dark Forest for title/closing, light Cream/white for content slides — "sandwich" structure already established |
| Documents (SRS, overview, etc.) | Cambria headers in Forest, Calibri body, consistent with existing generated docs |
| Marketing video | Real farmers, real fields, real phones — plain-spoken voiceover matching §1.1 tone, subtitles in French and English |
| Social / competition materials | Sprout mark + "Grow smarter, farm better" tagline as the consistent sign-off |

---

## 8. Accessibility Commitments (brand-level, not just technical)

- Minimum 4.5:1 text contrast against its background everywhere — no light text on Cream, no Moss text on white without a darker treatment.
- Never rely on color alone to convey meaning (confidence badges always carry a text label too).
- Icon + text pairing for every navigation element — never icon-only for a first-time user.
- Voice narration and a local-language option are brand commitments, not stretch goals — they're referenced consistently across the SRS, overview, and this guide because they materially affect who can actually use Orynta.
