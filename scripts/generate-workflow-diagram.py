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
import sys

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
    width = 1040
    height = 680

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

    # --- SECTION 1: SYSTEM GOVERNANCE (Top Container) ---
    svg.append(f'''  <!-- Zone 1: Governance Container -->
  <rect x="30" y="25" width="980" height="66" rx="10" fill="{t['bg_container']}" stroke="{t['border_container']}" stroke-width="1.5" />
  <text x="50" y="45" font-size="11" font-weight="700" fill="{t['text_muted']}" letter-spacing="0.08em">SYSTEM GOVERNANCE</text>

  <!-- Skill: maintain-agents-md -->
  <g transform="translate(195, 38)">
    <rect width="180" height="40" rx="8" fill="{t['bg_card']}" stroke="{t['plum_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="20" r="5" fill="{t['plum_main']}" />
    <text x="28" y="24" font-size="13" font-weight="600" fill="{t['text_main']}">maintain-agents-md</text>
  </g>

  <!-- Arrow from maintain-agents-md to AGENTS.md -->
  <path d="M 375 58 L 415 58" fill="none" stroke="{t['line_color']}" stroke-width="2" marker-end="url(#arrow-{theme_name})" />

  <!-- Artifact: AGENTS.md / CLAUDE.md -->
  <g transform="translate(425, 38)">
    <rect width="210" height="40" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="16" y="24" font-size="13" font-weight="600" fill="{t['text_main']}">AGENTS.md / CLAUDE.md</text>
  </g>

  <text x="655" y="63" font-size="12" fill="{t['text_muted']}">Lean rules (&lt; 200 lines) steering all agent sessions</text>
''')

    # --- SECTION 2: DISCOVERY, SPECIFICATION & RESEARCH ---
    svg.append(f'''  <!-- Zone 2: Discovery & Spec Container -->
  <rect x="30" y="110" width="980" height="225" rx="10" fill="{t['bg_container']}" stroke="{t['border_container']}" stroke-width="1.5" />
  <text x="50" y="132" font-size="11" font-weight="700" fill="{t['text_muted']}" letter-spacing="0.08em">DISCOVERY, SPECIFICATION &amp; RESEARCH</text>

  <!-- Row 1: Problem Space -> explore-ideas -> Backlog -->
  <!-- Input: Problem Space -->
  <g transform="translate(50, 150)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Problem space</text>
  </g>
  <path d="M 165 168 L 195 168" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Skill: explore-ideas -->
  <g transform="translate(205, 144)">
    <rect width="145" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="24" r="5" fill="{t['pink_main']}" />
    <text x="28" y="28" font-size="13" font-weight="600" fill="{t['text_main']}">explore-ideas</text>
  </g>
  <path d="M 350 168 L 380 168" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Artifact: docs/ideas/<area>.md -->
  <g transform="translate(390, 144)">
    <rect width="180" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="24" font-size="12" font-weight="600" fill="{t['text_main']}">docs/ideas/&lt;area&gt;.md</text>
    <text x="14" y="40" font-size="11" fill="{t['text_muted']}">Ranked idea backlog</text>
  </g>

  <!-- Curve: pick one idea from backlog down to shape-spec -->
  <path d="M 480 192 C 480 220 375 234 360 234" fill="none" stroke="{t['line_accent']}" stroke-width="1.5" stroke-dasharray="3 3" marker-end="url(#arrow-pink-{theme_name})" />
  <text x="440" y="215" font-size="10.5" font-weight="500" fill="{t['pink_main']}">pick one idea</text>

  <!-- Row 2: Concept -> shape-spec -> docs/<slug>/spec.md -->
  <!-- Input: Concept -->
  <g transform="translate(50, 216)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Broad concept</text>
  </g>
  <path d="M 165 234 L 195 234" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Skill: shape-spec -->
  <g transform="translate(205, 210)">
    <rect width="145" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="24" r="5" fill="{t['pink_main']}" />
    <text x="28" y="28" font-size="13" font-weight="600" fill="{t['text_main']}">shape-spec</text>
  </g>
  <path d="M 350 234 L 380 234" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Artifact: spec.md + milestones -->
  <g transform="translate(390, 210)">
    <rect width="180" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="24" font-size="12" font-weight="600" fill="{t['text_main']}">docs/&lt;slug&gt;/spec.md</text>
    <text x="14" y="40" font-size="11" fill="{t['text_muted']}">Confirmed spec + m1..mN/</text>
  </g>

  <!-- Row 3: Scoped Task -> deepen-task -> Hardened Spec -->
  <!-- Input: Task / Ticket -->
  <g transform="translate(50, 280)">
    <rect width="115" height="36" rx="18" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="22" font-size="12" font-weight="500" fill="{t['badge_text']}">Focused task</text>
  </g>
  <path d="M 165 298 L 195 298" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Skill: deepen-task -->
  <g transform="translate(205, 274)">
    <rect width="145" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="16" cy="24" r="5" fill="{t['pink_main']}" />
    <text x="28" y="28" font-size="13" font-weight="600" fill="{t['text_main']}">deepen-task</text>
  </g>
  <path d="M 350 298 L 380 298" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Artifact: Hardened Task Specification -->
  <g transform="translate(390, 274)">
    <rect width="180" height="48" rx="8" fill="{t['bg_card']}" stroke="{t['border_card']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <text x="14" y="24" font-size="12" font-weight="600" fill="{t['text_main']}">Hardened Spec</text>
    <text x="14" y="40" font-size="11" fill="{t['text_muted']}">Deeper, not bigger (no bloat)</text>
  </g>

  <!-- Cross-Cutting Research Component -->
  <g transform="translate(680, 175)">
    <rect width="300" height="110" rx="8" fill="{t['bg_card']}" stroke="{t['blue_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="28" r="5" fill="{t['blue_main']}" />
    <text x="34" y="32" font-size="14" font-weight="600" fill="{t['text_main']}">research-topic</text>
    <path d="M 20 48 L 280 48" stroke="{t['border_card']}" stroke-width="1" />
    <text x="20" y="68" font-size="12" font-weight="600" fill="{t['blue_text']}">docs/research/ (Corpus)</text>
    <text x="20" y="86" font-size="11" fill="{t['text_muted']}">Sourced, verified findings</text>
    <text x="20" y="100" font-size="10.5" font-style="italic" fill="{t['text_muted']}">Consulted across all stages</text>
  </g>
''')

    # --- SECTION 3: PLANNING & EXECUTION ---
    svg.append(f'''  <!-- Connector from spec.md down to plan-work -->
  <path d="M 480 258 L 480 365" fill="none" stroke="{t['line_color']}" stroke-width="2" marker-end="url(#arrow-{theme_name})" />
  <!-- Connector from deepen-task spec into plan-work -->
  <path d="M 570 298 C 610 298 610 395 595 395" fill="none" stroke="{t['line_color']}" stroke-width="1.5" stroke-dasharray="3 3" />

  <!-- Planning Box: plan-work -->
  <g transform="translate(370, 370)">
    <rect width="225" height="60" rx="8" fill="{t['bg_card']}" stroke="{t['amber_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="24" r="5" fill="{t['amber_main']}" />
    <text x="32" y="28" font-size="14" font-weight="600" fill="{t['text_main']}">plan-work</text>
    <text x="32" y="46" font-size="11.5" fill="{t['text_muted']}">docs/&lt;slug&gt;/[m&lt;N&gt;/]plan.md</text>
    <rect x="120" y="14" width="92" height="18" rx="9" fill="{t['amber_bg']}" stroke="{t['amber_border']}" stroke-width="1" />
    <text x="128" y="27" font-size="9.5" font-weight="600" fill="{t['amber_text']}">≤ 8 phases / 40 tasks</text>
  </g>

  <!-- Execution Splitter lines -->
  <path d="M 430 430 C 430 455 310 455 310 478" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />
  <path d="M 535 430 C 535 455 645 455 645 478" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Execution Mode 1: execute-plan (inline) -->
  <g transform="translate(195, 485)">
    <rect width="230" height="64" rx="8" fill="{t['bg_card']}" stroke="{t['pink_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="24" r="5" fill="{t['pink_main']}" />
    <text x="32" y="28" font-size="13.5" font-weight="600" fill="{t['text_main']}">execute-plan</text>
    <text x="32" y="47" font-size="11" fill="{t['text_muted']}">Inline in main session</text>
    <rect x="145" y="14" width="72" height="18" rx="9" fill="{t['pink_bg']}" stroke="{t['pink_border']}" stroke-width="1" />
    <text x="153" y="27" font-size="9.5" font-weight="600" fill="{t['pink_text']}">Main session</text>
  </g>

  <!-- Execution Mode 2: execute-plan-with-subagents -->
  <g transform="translate(530, 485)">
    <rect width="235" height="64" rx="8" fill="{t['bg_card']}" stroke="{t['plum_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="20" cy="24" r="5" fill="{t['plum_main']}" />
    <text x="32" y="28" font-size="13" font-weight="600" fill="{t['text_main']}">execute-plan-with-subagents</text>
    <text x="32" y="47" font-size="11" fill="{t['text_muted']}">Supervisor + phase workers</text>
    <rect x="145" y="14" width="78" height="18" rx="9" fill="{t['plum_bg']}" stroke="{t['plum_border']}" stroke-width="1" />
    <text x="153" y="27" font-size="9.5" font-weight="600" fill="{t['plum_main']}">Subagent tier</text>
  </g>

  <!-- Join into Verified Milestone -->
  <path d="M 310 549 C 310 575 440 575 440 595" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />
  <path d="M 645 549 C 645 575 520 575 520 595" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

  <!-- Output: Verified Milestone -->
  <g transform="translate(385, 602)">
    <rect width="190" height="48" rx="24" fill="{t['emerald_bg']}" stroke="{t['emerald_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
    <circle cx="22" cy="24" r="6" fill="{t['emerald_main']}" />
    <text x="36" y="29" font-size="13" font-weight="700" fill="{t['emerald_text']}">Verified Milestone</text>
  </g>

  <!-- Loop: Next milestone back to plan-work -->
  <path d="M 575 626 C 800 626 800 400 605 400" fill="none" stroke="{t['emerald_main']}" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arrow-emerald-{theme_name})" />
  <text x="808" y="500" font-size="11" font-weight="600" fill="{t['emerald_text']}">next milestone</text>
''')

    # --- SECTION 4: DIAGNOSTICS & ROOT CAUSE (five-whys) ---
    svg.append(f'''  <!-- Diagnostics: five-whys -->
  <g transform="translate(820, 560)">
    <!-- Failure Input Badge -->
    <rect x="0" y="-36" width="165" height="26" rx="13" fill="{t['badge_bg']}" stroke="{t['badge_border']}" stroke-width="1" />
    <text x="14" y="-19" font-size="11" font-weight="600" fill="{t['badge_text']}">Failure / flake / bug</text>

    <!-- Arrow from input to five-whys -->
    <path d="M 82 -10 L 82 8" fill="none" stroke="{t['line_color']}" stroke-width="1.5" marker-end="url(#arrow-{theme_name})" />

    <!-- Card: five-whys -->
    <rect width="165" height="68" rx="8" fill="{t['bg_card']}" stroke="{t['amber_border']}" stroke-width="1.5" filter="url(#shadow-{theme_name})" />
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
