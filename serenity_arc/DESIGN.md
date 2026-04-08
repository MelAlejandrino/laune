# Design System Document: The Mindful Canvas

## 1. Overview & Creative North Star: "The Digital Sanctuary"
The objective of this design system is to transition the user from the chaotic outside world into a space of internal reflection. We are moving away from the "utility app" aesthetic and toward a **Digital Sanctuary**—an editorial-inspired, high-end experience that feels more like a premium wellness journal than a data tracker.

### The Creative North Star: "Soft Editorial"
Unlike standard mobile apps that rely on rigid grids and heavy borders, this system utilizes **intentional asymmetry** and **tonal depth**. We treat the mobile screen as a physical space where elements float and breathe. By using aggressive whitespace and a sophisticated typography scale, we guide the user’s eye through a narrative of their own emotional well-being, ensuring the interface never feels "busy" or "anxious."

---

## 2. Colors: Tonal Atmosphere
We use a sophisticated palette where the "primary" and "secondary" colors are not just accents, but atmospheric washes. The entire system draws from the warmth of candlelight, linen, and aged parchment — never clinical, never cold.

### The Palette (Material Design Tokens)
*   **Primary (Dusty Rose):** `#B07080` — The anchor for action and focus. A muted, warm rose that feels intentional without being loud.
*   **On Primary:** `#FFF5F0` — Soft cream text on primary surfaces.
*   **Primary Container:** `#F2D4D4` — Blush tint used for chips, selected states, and secondary CTAs.
*   **On Primary Container:** `#7A4050` — Deep rose for readable text within primary containers.
*   **Secondary (Muted Lavender):** `#8E7FA8` — Depth and reflection; used for secondary insights, mood tags, and companion accents.
*   **On Secondary:** `#F8F4FF` — Near-white warm tint for text on secondary.
*   **Secondary Container:** `#DDD8EE` — Soft lavender wash for secondary chips and badges.
*   **On Secondary Container:** `#5A4A72` — Deep muted violet for readable secondary labels.
*   **Tertiary (Sage Green):** `#7A9E8E` — Calm affirmation; used for streaks, positive reinforcement states.
*   **Surface Hierarchy (All warm-cream, never blue-tinted):**
    *   `surface`: `#FDF8F2` — Warm parchment; the primary canvas.
    *   `surface_container_low`: `#F7EFE5` — Linen; secondary sections and card underlays.
    *   `surface_container`: `#F0E5D8` — Warm sand; grouped content areas.
    *   `surface_container_high`: `#E8D8C8` — Toasted cream; raised card backgrounds.
    *   `surface_container_highest`: `#DECCB8` — Warm beige; the topmost elevated card surface.
    *   `surface_container_lowest`: `#FBF5EE` — Lightest warm tint; hero section backgrounds.
*   **On Surface:** `#3D2B1F` — Deep warm brown, replaces cold navy. The primary readable text tone.
*   **On Surface Variant:** `#7A6055` — Muted sienna; secondary labels, captions, quiet metadata.
*   **Outline:** `#B89880` — Warm taupe; the Ghost Border fallback (used at 15% opacity max).
*   **Outline Variant:** `#D4B89A` — Pale sand for subtle separators where absolutely required.
*   **Error:** `#B05050` — A warm muted crimson, consistent with the overall soft tone.
*   **On Error:** `#FFF2F0` — Warm cream on error surfaces.

### The "No-Line" Rule
**Explicit Instruction:** Traditional 1px solid borders are prohibited for sectioning. We define boundaries through background color shifts. To separate a header from a list, do not draw a line; instead, transition from `surface` (`#FDF8F2`) to `surface_container_low` (`#F7EFE5`).

### Surface Hierarchy & Nesting
Treat the UI as a series of layered, frosted linen sheets.
*   **Rule:** Always nest "lighter" (higher elevation) surfaces on "darker" (lower elevation) ones. A `surface_container_lowest` (`#FBF5EE`) card should sit atop a `surface_container` (`#F0E5D8`) background to create a natural, "lifted" feel without artificial outlines.

### The "Glass & Gradient" Rule
For floating action buttons or hero mood cards, use a **Backdrop Blur** (12px–20px) with the `surface_variant` token at 60% opacity. For primary CTAs, use a subtle linear gradient from `primary` (`#B07080`) to a 10% darker warm rose (`#956070`) at 135 degrees to add a tactile, premium weight.

---

## 3. Typography: The Editorial Voice
We utilize a pairing of **Plus Jakarta Sans** for high-impact display and **Manrope** for focused reading. This creates a "Wellness Magazine" feel.

*   **Display (Plus Jakarta Sans):** Used for large mood indicators and daily summaries. `display-lg` (3.5rem) should feel monumental and airy.
*   **Headline (Plus Jakarta Sans):** Used for section titles. `headline-md` (1.75rem) provides authority without aggression.
*   **Body & Labels (Manrope):** Optimized for long-form reflection. `body-lg` (1rem) is the default for journal entries, ensuring maximum legibility with a generous line-height (1.6).

**Hierarchy Principle:** Use `on_surface_variant` (`#7A6055`) for secondary labels to create a soft, warm contrast against the primary `on_surface` (`#3D2B1F`) text. Avoid `#000000` and cold-gray neutrals at all costs. All text tints must carry a warm brown or sienna undertone.

---

## 4. Elevation & Depth: Tonal Layering
In this system, depth is a feeling, not a shadow.

*   **The Layering Principle:** Avoid the "flat" look by stacking.
    *   *Example:* Level 0: `surface` -> Level 1: `surface_container` -> Level 2: `surface_container_highest`.
*   **Ambient Shadows:** When an element must float (e.g., a "Log Mood" button), use an extra-diffused shadow. 
    *   *Spec:* `0px 12px 32px rgba(61, 43, 31, 0.07)`. The tint is derived from `on_surface` (`#3D2B1F`) to keep it warm and natural.
*   **The "Ghost Border" Fallback:** If a container lacks contrast (e.g., in dark mode or accessibility high-contrast), use a `outline_variant` at **15% opacity**. This creates a hint of an edge without breaking the "No-Line" rule.

---

## 5. Components: The Primitive Set

### Buttons (The "Pill" Shape)
*   **Primary:** Full rounded (`9999px`), `primary` background, `on_primary` text. Use a 4px horizontal inner-glow for a 3D "glass" effect.
*   **Secondary:** `secondary_container` background with `on_secondary_container` text. No border.

### Mood Cards (The Core Experience)
*   **Design:** Use `xl` (3rem) rounded corners for the outer container. 
*   **Layout:** Forbid dividers. Use `md` (1.5rem) spacing between the "Mood Icon" and the "Mood Label."
*   **Dynamic Accents:** Use the PRD mood colors (e.g., `teal-400`, `amber-500`) as small, glowing "indicator pips" or background washes behind Lucide icons.

### Input Fields (Journaling)
*   **Style:** Background-only inputs using `surface_container_low`. 
*   **Focus State:** Smooth transition to `surface_container_highest` with a `primary` "Ghost Border" (20% opacity).
*   **Shadows:** Inset shadows are forbidden; we prefer the "pressed-in" look achieved through a slightly darker background color.

### Mood Sliders (The Signature Component)
Instead of a standard slider, use a broad, thick track (24px height) with `primary_fixed_dim`. The thumb should be a large, `full` rounded circle with an ambient shadow to make it feel tactile and easy to slide.

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use asymmetrical margins (e.g., 24px on the left, 32px on the right) for title headers to create a custom editorial look.
*   **Do** use Lucide icons with a `stroke-width` of 1.5px to maintain the "airy" feel.
*   **Do** embrace negative space. If a screen feels "full," remove a container and use a background color shift instead.

### Don't:
*   **Don't** use 1px solid lines to separate content. Use the spacing scale (`lg` - 2rem) or background tiers.
*   **Don't** use pure black or pure grey. Use the `on_surface` (`#3D2B1F`) and `outline` (`#B89880`) tints to maintain the warm, cozy soul of the system. Cool grays and blue-tinted neutrals are strictly prohibited.
*   **Don't** use sharp corners. The minimum radius is `DEFAULT` (1rem / 16px). Everything must feel soft to the touch.

---
*End of Document*