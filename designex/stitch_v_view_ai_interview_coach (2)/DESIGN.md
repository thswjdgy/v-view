---
name: V-View Design System
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f7'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2ff'
  on-surface: '#131b30'
  on-surface-variant: '#3c4a45'
  inverse-surface: '#283046'
  inverse-on-surface: '#eef0ff'
  outline: '#6b7a75'
  outline-variant: '#bacac3'
  surface-tint: '#006b58'
  primary: '#006b58'
  on-primary: '#ffffff'
  primary-container: '#00c9a7'
  on-primary-container: '#004e40'
  inverse-primary: '#38debb'
  secondary: '#ae2f34'
  on-secondary: '#ffffff'
  secondary-container: '#ff6b6b'
  on-secondary-container: '#6d0010'
  tertiary: '#005db8'
  on-tertiary: '#ffffff'
  tertiary-container: '#87b3ff'
  on-tertiary-container: '#004489'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#5ffbd6'
  primary-fixed-dim: '#38debb'
  on-primary-fixed: '#002019'
  on-primary-fixed-variant: '#005142'
  secondary-fixed: '#ffdad8'
  secondary-fixed-dim: '#ffb3b0'
  on-secondary-fixed: '#410006'
  on-secondary-fixed-variant: '#8c1520'
  tertiary-fixed: '#d6e3ff'
  tertiary-fixed-dim: '#a9c7ff'
  on-tertiary-fixed: '#001b3e'
  on-tertiary-fixed-variant: '#00468c'
  background: '#faf8ff'
  on-background: '#131b30'
  surface-variant: '#dae2ff'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-bold:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
  caption:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 40px
  container-max: 1200px
  gutter: 20px
---

## Brand & Style
The design system is centered on a "Gamified Achievement" aesthetic, drawing inspiration from high-engagement educational platforms. The personality is encouraging, approachable, and vibrant, designed to reduce the anxiety typically associated with interview preparation.

The style utilizes **Soft-Minimalism** with a **Tactile** twist. Elements feel physical and "pressable," using subtle depth to guide the user's journey. The interface prioritizes clarity and whitespace to ensure that AI-driven feedback remains the focal point without overwhelming the user.

**The Mascot: V-Bot**
To personify the AI, the design system introduces "V-Bot"—a friendly, stylized robot with a rounded, pill-shaped body and expressive digital eyes. V-Bot appears in different emotional states: 
- **Encouraging:** Cheering with a "Fighting!" gesture for completed sessions.
- **Attentive:** Holding a clipboard during mock interviews.
- **Thinking:** Displaying a processing icon when generating feedback.
V-Bot should always be rendered in the primary Mint-Teal with a Secondary Coral bowtie or accent.

## Colors
This design system uses a high-energy palette to keep users motivated. 
- **Primary (Mint-Teal):** Used for "Success" states, primary progress indicators, and the main action buttons. It signals growth and positivity.
- **Secondary (Coral):** Reserved for "Urgent" prompts, streak highlights, and critical feedback. It provides a warm contrast to the teal.
- **Text (Dark Navy):** Ensures high legibility and a touch of professional authority against the playful palette.
- **Surface (Light Gray):** Used for card backgrounds and inactive states to create a subtle layered effect against the white background.

## Typography
The typography is optimized for Korean (Hangul) and English characters. **Plus Jakarta Sans** is used for headings and labels to provide a soft, modern geometric feel. **Be Vietnam Pro** is used for body text due to its exceptional readability and friendly letterforms.

- **Weight Usage:** Use Bold (700) or ExtraBold (800) for headlines to create a "pop" effect.
- **Line Height:** Generous line heights are maintained to ensure that feedback text (which can be dense) remains inviting to read.
- **Korean Optimization:** When rendering Korean text, reduce letter-spacing by -0.01em for headlines to maintain a tight, professional look.

## Layout & Spacing
The layout uses a **Fluid Grid** system based on an 8px rhythm. 
- **Desktop:** 12-column grid with 24px gutters.
- **Mobile:** 4-column grid with 16px margins.

Cards are the primary container for all content. Spacing inside cards should be generous (24px padding) to prevent the AI feedback from feeling cramped. Elements are often grouped within "Section" containers using the Light Gray (`#F5F7FA`) color to differentiate between types of interview questions or feedback categories.

## Elevation & Depth
Depth in this design system is achieved through **Tactile Shadowing** rather than traditional blurs.
- **Level 1 (Default Cards):** A soft, subtle shadow (`Y: 4, Blur: 12, Opacity: 0.05, Color: #1A2238`) is used to lift cards off the background.
- **Level 2 (Active/Buttons):** Buttons use a "3D Border" effect—a bottom border of 4px in a darker shade of the button's color to simulate a physical button that can be pressed.
- **Level 3 (Modals):** Large blurs and a semi-transparent backdrop to focus the user on critical V-Bot messages or session results.

## Shapes
Shapes are intentionally "Chubby" and friendly. 
- **Standard Corners:** 16px is the base radius for all cards and buttons.
- **Large Containers:** 24px for main dashboard sections.
- **Pills:** 100px for tags, category chips, and progress bar caps.

Avoid sharp 90-degree angles entirely to maintain the "Encouraging" brand promise. All interactive borders should be at least 2px thick to feel substantial and high-quality.

## Components
### Buttons
Primary buttons use the Mint-Teal background with a 4px bottom "press" shadow. Labels are Bold 18px. Secondary buttons use a white background with a 2px Mint-Teal border.

### Feedback Cards
Cards display AI insights using a combination of the Secondary Coral for "Areas to Improve" and Primary Mint-Teal for "Strengths." Each card should feature a small V-Bot icon in the corner to make the feedback feel like it is coming from a mentor.

### Progress Bars
Thick, 12px height bars with rounded caps. The track is Light Gray, and the fill is a gradient of Mint-Teal. When a user reaches a milestone, the bar should trigger a "pulse" animation.

### Input Fields
Large, accessible fields with 16px padding and 16px corner radius. The border turns Mint-Teal on focus. Labels for inputs should always be in the "Label-Bold" typography style, placed above the field.

### Selection Chips
Used for choosing interview topics (e.g., "기술 면접", "인성 면접"). Chips should have a pill shape and "bounce" slightly when tapped, changing from Light Gray to Primary Mint-Teal.