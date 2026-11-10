#!/usr/bin/env python3
"""
Generate publication-quality SVG workflow diagrams for PinkRoosterSkills.
Zero dependencies: standard library Python only.
Generates:
  - assets/workflow-light.svg
  - assets/workflow-dark.svg
  - assets/workflow.svg (default / light fallback)
"""

import os

THEMES = {
    "light": {
        "bg_canvas": "#FFFFFF",
        "bg_container": "#F8FAFC",
        "border_container": "#E2E8F0",
        "bg_card": "#FFFFFF",
        "border_card": "#CBD5E1",
        "text_main": "#0F172A",
        "text_muted": "#64748B",
        "text_inverse": "#FFFFFF",
        "line_color": "#94A3B8",
        "line_accent": "#DE245F",
        "badge_bg": "#F1F5F9",
        "badge_border": "#CBD5E1",
        "badge_text": "#475569",
        # Accents
        "pink_main": "#DE245F",
        "pink_bg": "#FFF1F5",
        "pink_border": "#FDA4AF",
        "pink_text": "#BE123C",
        "plum_main": "#811B53",
        "plum_bg": "#FDF2F8",
        "plum_border": "#F472B6",
        "emerald_main": "#10B981",
        "emerald_bg": "#ECFDF5",
        "emerald_border": "#6EE7B7",
        "emerald_text": "#047857",
        "amber_main": "#F59E0B",
        "amber_bg": "#FFFBEB",
        "amber_border": "#FCD34D",
        "amber_text": "#B45309",
        "blue_main": "#3B82F6",
        "blue_bg": "#EFF6FF",
        "blue_border": "#93C5FD",
        "blue_text": "#1D4ED8",
        "shadow": "rgba(0,0,0,0.04)"
    },
    "dark": {
        "bg_canvas": "#0D1117",
        "bg_container": "#161B22",
        "border_container": "#30363D",
        "bg_card": "#21262D",
        "border_card": "#30363D",
        "text_main": "#F0F6FC",
        "text_muted": "#8B949E",
        "text_inverse": "#0D1117",
        "line_color": "#6E7681",
        "line_accent": "#F43F5E",
        "badge_bg": "#30363D",
        "badge_border": "#484F58",
        "badge_text": "#C9D1D9",
        # Accents
        "pink_main": "#F43F5E",
        "pink_bg": "#3A1424",
        "pink_border": "#FB7185",
        "pink_text": "#FDA4AF",
        "plum_main": "#A82B70",
        "plum_bg": "#2E1225",
        "plum_border": "#E879F9",
        "emerald_main": "#10B981",
        "emerald_bg": "#0D2E24",
        "emerald_border": "#34D399",
        "emerald_text": "#6EE7B7",
        "amber_main": "#F59E0B",
        "amber_bg": "#33220A",
        "amber_border": "#FBBF24",
        "amber_text": "#FDE68A",
        "blue_main": "#3B82F6",
        "blue_bg": "#13233A",
        "blue_border": "#60A5FA",
        "blue_text": "#93C5FD",
        "shadow": "rgba(0,0,0,0.3)"
    }
}


def build_svg(theme_name: str) -> str:
    t = THEMES[theme_name]
    width = 1060
    height = 690

    svg = []
    svg.append(f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {width} {height}" width="100%" height="100%" style="background-color: {t['bg_canvas']}; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;">
  <defs>
    <!-- Arrowhead markers -->
    <marker id="arrow-{theme_name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="{t['line_color']}" />
    </marker>
    <marker id="arrow-pink-{theme_name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="{t['pink_main']}" />
    </marker>
    <marker id="arrow-emerald-{theme_name}" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse">
      <path d="M 0 1.5 L 8 5 L 0 8.5 z" fill="{t['emerald_main']}" />
    </marker>
    <!-- Subtle drop shadow -->
    <filter id="shadow-{theme_name}" x="-4%" y="-4%" width="108%" height="108%">
      <feDropShadow dx="0" dy="2" stdDeviation="3" flood-color="{t['shadow']}" />
    </filter>
  </defs>
''')

    # Background canvas
    svg.append(f'  <rect width="{width}" height="{height}" fill="{t["bg_canvas"]}" />\n')

    # =========================================================================
    # ZONE 1: SYSTEM GOVERNANCE (Top Container)
    # =========================================================================
    svg.append(f'''  <!-- Zone 1: Governance Container -->
  <rect x="30" y="25" width="1000" height="64" rx="10" fill="{t['bg_container']}" stroke="{t['border_container']}" stroke-width="1.5" />
  <text x="50" y="45" font-size="11" font-weight="700" fill="{t['text_muted']}" letter-spacing="0.08em">SYSTEM GOVERNANCE</text>

  <!-- Skill: maintain-agents-md -->
  <g transform="translate(195, 37)">
    <rect width="180" height="40" rx="8" fill="{t['bg_card']}" stroke="{t['plum_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="20" r="5" fill="{t['plum_main']}" />
    <text x="28" y="24" font-size="13" font-weight="600" fill="{t['text_main']}">maintain-agents-md</text>
  </g>

  <!-- Arrow from maintain-agents-md to AGENTS.md -->
  <path d="M 375 57 L 415 57" fill="none" stroke="{t['line_color']}" stroke-width="2" marker-end="url(#arrow-{theme_name})" />

  <!-- Artifact: AGENTS.md / CLAUDE.md -->
  <g transform="translate(425, 37)">
    <rect width="210" height="40" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="16" y="24" font-size="13" font-weight="600" fill="{t['text_main']}">AGENTS.md / CLAUDE.md</text>
  </g>

  <text x="655" y="62" font-size="12" fill="{t['text_muted']}">Lean rules (&lt; 200 lines) steering all agent sessions</text>
''')

    # =========================================================================
    # ZONE 2: DISCOVERY, SPECIFICATION & RESEARCH
    # =========================================================================
    svg.append(f'''  <!-- Zone 2: Discovery & Spec Container -->
  <rect x="30" y="105" width="1000" height="235" rx="10" fill="{t['bg_container']}" stroke="{t['border_container']}" stroke-width="1.5" />
  <text x="50" y="126" font-size="11" font-weight="700" fill="{t['text_muted']}" letter-spacing="0.08em">DISCOVERY, SPECIFICATION &amp; RESEARCH</text>

  <!-- Row 1: Problem Space -> explore-ideas -> Backlog (y = 138..182) -->
  <g transform="translate(50, 142)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Problem space</text>
  </g>
  <path d="M 165 160 L 195 160" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(205, 138)">
    <rect width="145" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="22" r="5" fill="{t['pink_main']}" />
    <text x="28" y="26" font-size="13" font-weight="600" fill="{t['text_main']}">explore-ideas</text>
  </g>
  <path d="M 350 160 L 380 160" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(390, 138)">
    <rect width="180" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="21" font-size="12" font-weight="600" fill="{t['text_main']}">docs/ideas/&lt;area&gt;.md</text>
    <text x="14" y="36" font-size="10.5" fill="{t['text_muted']}">Ranked idea backlog</text>
  </g>

  <!-- Curve: pick one idea from backlog to shape-spec (completely clear of both cards) -->
  <path d="M 430 182 C 430 198, 310 194, 310 210" fill="none" stroke="{t['pink_main']}" stroke-width="1.5" stroke-dasharray="3 3" marker-end="url(#arrow-pink-{theme_name})" />
  <rect x="340" y="188" width="76" height="16" rx="8" fill="{t['pink_bg']}" stroke="{t['pink_border']}" stroke-width="0.8" />
  <text x="346" y="200" font-size="9.5" font-weight="600" fill="{t['pink_text']}">pick one idea</text>

  <!-- Row 2: Concept -> shape-spec -> docs/<slug>/spec.md (y = 212..256) -->
  <g transform="translate(50, 216)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Broad concept</text>
  </g>
  <path d="M 165 234 L 195 234" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(205, 212)">
    <rect width="145" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="22" r="5" fill="{t['pink_main']}" />
    <text x="28" y="26" font-size="13" font-weight="600" fill="{t['text_main']}">shape-spec</text>
  </g>
  <path d="M 350 234 L 380 234" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(390, 212)">
    <rect width="180" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="21" font-size="12" font-weight="600" fill="{t['text_main']}">docs/&lt;slug&gt;/spec.md</text>
    <text x="14" y="36" font-size="10.5" fill="{t['text_muted']}">Confirmed spec + m1..mN/</text>
  </g>

  <!-- Row 3: Scoped Task -> deepen-task -> Hardened Spec (y = 282..326) -->
  <g transform="translate(50, 286)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Focused task</text>
  </g>
  <path d="M 165 304 L 195 304" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(205, 282)">
    <rect width="145" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="22" r="5" fill="{t['pink_main']}" />
    <text x="28" y="26" font-size="13" font-weight="600" fill="{t['text_main']}">deepen-task</text>
  </g>
  <path d="M 350 304 L 380 304" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <g transform="translate(390, 282)">
    <rect width="180" height="44" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="21" font-size="12" font-weight="600" fill="{t['text_main']}">Hardened Spec</text>
    <text x="14" y="36" font-size="10.5" fill="{t['text_muted']}">Deeper, not bigger (no bloat)</text>
  </g>

  <!-- Research Component: Self-contained shared corpus -->
  <g transform="translate(710, 160)">
    <rect width="290" height="120" rx="8" fill="{t['bg_card']}" stroke="{t['blue_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="26" r="5" fill="{t['blue_main']}" />
    <text x="34" y="30" font-size="14" font-weight="600" fill="{t['text_main']}">research-topic</text>
    <path d="M 20 44 L 270 44" stroke="{t['border_card']}" stroke-width="1" />
    <text x="20" y="66" font-size="12.5" font-weight="600" fill="{t['blue_text']}">docs/research/ (Corpus)</text>
    <text x="20" y="86" font-size="11" fill="{t['text_muted']}">Sourced, verified knowledge base</text>
    <text x="20" y="103" font-size="11" font-style="italic" fill="{t['text_muted']}">Consulted across all stages</text>
  </g>
''')

    # =========================================================================
    # ZONE 3: PLANNING & EXECUTION
    # =========================================================================
    svg.append(f'''  <!-- Unobstructed connection paths into plan-work -->
  <!-- 1. spec.md curves through clear channel into plan-work (landing cleanly at x = 485, away from badge) -->
  <path d="M 570 234 C 615 234, 615 330, 485 348 L 485 373" fill="none" stroke="{t['line_color']}" stroke-width="1.8" marker-end="url(#arrow-{theme_name})" />

  <!-- 2. Hardened Spec connects directly down into plan-work (landing cleanly at x = 430) -->
  <path d="M 430 326 L 430 368" fill="none" stroke="{t['line_color']}" stroke-width="1.5" stroke-dasharray="3 3" marker-end="url(#arrow-{theme_name})" />

  <!-- Planning Box: plan-work -->
  <g transform="translate(370, 375)">
    <rect width="235" height="64" rx="8" fill="{t['bg_card']}" stroke="{t['amber_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="18" cy="22" r="5" fill="{t['amber_main']}" />
    <text x="30" y="26" font-size="14" font-weight="600" fill="{t['text_main']}">plan-work</text>
    <text x="30" y="47" font-size="11.5" fill="{t['text_muted']}">docs/&lt;slug&gt;/[m&lt;N&gt;/]plan.md</text>
    <rect x="135" y="14" width="90" height="18" rx="9" fill="{t['amber_bg']}" stroke="{t['amber_border']}" stroke-width="1" />
    <text x="141" y="27" font-size="9" font-weight="600" fill="{t['amber_text']}">≤ 8 phases / 40 tasks</text>
  </g>

  <!-- Execution Splitter lines -->
  <path d="M 425 439 C 425 460 300 460 300 482" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />
  <path d="M 545 439 C 545 460 610 460 610 482" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Execution Mode 1: execute-plan (inline) -->
  <g transform="translate(185, 488)">
    <rect width="230" height="66" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="18" cy="22" r="5" fill="{t['pink_main']}" />
    <text x="30" y="26" font-size="13.5" font-weight="600" fill="{t['text_main']}">execute-plan</text>
    <text x="30" y="48" font-size="11" fill="{t['text_muted']}">Inline in main session</text>
    <rect x="145" y="14" width="75" height="18" rx="9" fill="{t['pink_bg']}" stroke="{t['pink_border']}" stroke-width="1" />
    <text x="153" y="27" font-size="9.5" font-weight="600" fill="{t['pink_text']}">Main session</text>
  </g>

  <!-- Execution Mode 2: execute-plan-with-subagents (width 255, badge at x=172 with generous clearance) -->
  <g transform="translate(480, 488)">
    <rect width="255" height="66" rx="8" fill="{t['bg_card']}" stroke="{t['plum_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="18" cy="22" r="5" fill="{t['plum_main']}" />
    <text x="30" y="26" font-size="13" font-weight="600" fill="{t['text_main']}">execute-plan-with-subagents</text>
    <text x="30" y="48" font-size="11" fill="{t['text_muted']}">Supervisor + phase workers</text>
    <rect x="172" y="38" width="75" height="18" rx="9" fill="{t['plum_bg']}" stroke="{t['plum_border']}" stroke-width="1" />
    <text x="180" y="51" font-size="9.5" font-weight="600" fill="{t['plum_main']}">Subagents</text>
  </g>

  <!-- Join into Verified Milestone -->
  <path d="M 300 554 C 300 580 440 580 440 604" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />
  <path d="M 610 554 C 610 580 520 580 520 604" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Output: Verified Milestone -->
  <g transform="translate(385, 610)">
    <rect width="190" height="48" rx="24" fill="{t['emerald_bg']}" stroke="{t['emerald_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="22" cy="24" r="6" fill="{t['emerald_main']}" />
    <text x="36" y="29" font-size="13" font-weight="700" fill="{t['emerald_text']}">Verified Milestone</text>
  </g>

  <!-- Loop: Next milestone routed cleanly through wide corridor between 735 and 860 -->
  <path d="M 575 634 L 795 634 L 795 407 L 610 407" fill="none" stroke="{t['emerald_main']}" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arrow-emerald-{theme_name})" />
  <rect x="752" y="510" width="86" height="20" rx="10" fill="{t['emerald_bg']}" stroke="{t['emerald_border']}" stroke-width="1" />
  <text x="758" y="524" font-size="10" font-weight="600" fill="{t['emerald_text']}">next milestone</text>
''')

    # =========================================================================
    # ZONE 4: DIAGNOSTICS & ROOT CAUSE (five-whys)
    # =========================================================================
    svg.append(f'''  <!-- Diagnostics: five-whys (x = 860) -->
  <g transform="translate(860, 560)">
    <!-- Failure Input Badge -->
    <rect x="0" y="-36" width="160" height="26" rx="13" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="-19" font-size="11" font-weight="600" fill="{t['badge_text']}">Failure / flake / bug</text>

    <!-- Arrow from input to five-whys -->
    <path d="M 80 -10 L 80 8" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

    <!-- Card: five-whys -->
    <rect width="160" height="68" rx="8" fill="{t['bg_card']}" stroke="{t['amber_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="24" r="5" fill="{t['amber_main']}" />
    <text x="32" y="28" font-size="13.5" font-weight="600" fill="{t['text_main']}">five-whys</text>
    <text x="16" y="47" font-size="11" fill="{t['text_muted']}">Root-cause diagnosis</text>
    <text x="16" y="60" font-size="10.5" font-weight="600" fill="{t['amber_text']}">Diagnose &amp; stop (no edits)</text>
  </g>
''')

    svg.append('</svg>\n')
    return ''.join(svg)


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    assets_dir = os.path.join(repo_root, "assets")
    os.makedirs(assets_dir, exist_ok=True)

    light_svg = build_svg("light")
    dark_svg = build_svg("dark")

    light_path = os.path.join(assets_dir, "workflow-light.svg")
    dark_path = os.path.join(assets_dir, "workflow-dark.svg")
    default_path = os.path.join(assets_dir, "workflow.svg")

    with open(light_path, "w", encoding="utf-8") as f:
        f.write(light_svg)
    with open(dark_path, "w", encoding="utf-8") as f:
        f.write(dark_svg)
    with open(default_path, "w", encoding="utf-8") as f:
        f.write(light_svg)

    print(f"Generated: {light_path}")
    print(f"Generated: {dark_path}")
    print(f"Generated: {default_path}")


if __name__ == "__main__":
    main()
