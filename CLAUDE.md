# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Tombolo is a dual-stack Ruby gem + npm package providing minimal React component mounting for Rails. It replaces react-rails with a simpler approach: a `react_component` view helper, client-side mounting via a component map, and optional server-side rendering via ExecJS.

## Commands

### Ruby

```sh
bundle exec rake test           # Run all minitest tests
bundle exec ruby -Ilib:test test/view_helper_test.rb  # Run a single test file
bundle exec rubocop             # Lint Ruby code
```

### TypeScript

```sh
pnpm install                    # Install dependencies
pnpm test                       # Run vitest
pnpm build                      # Compile TypeScript to dist/
pnpm lint                       # ESLint
pnpm prettier                   # Check formatting
pnpm prettier:fix               # Fix formatting
```

## Architecture

The gem has two halves that work together:

**Ruby side** (`lib/tombolo/`) — Rails integration:
- `view_helper.rb` — `react_component` helper that renders a `<div>` with `data-react-component` and `data-react-props` attributes
- `renderer.rb` — Thread-safe SSR via ExecJS, evaluates a JS bundle and calls `renderComponent`
- `configuration.rb` — Global config (`camelize_props`, `server_bundle` path)
- `railtie.rb` — Auto-includes ViewHelper into ActionView

**TypeScript side** (`src/`) — Client and server mounting:
- `index.ts` — `mount(components, scope?)`, `unmount(scope?)`, `start(components)` — scans DOM for `data-react-component` elements and manages React roots
- `server.ts` — `registerServerRenderer(components)` — exposes `renderComponent` on `globalThis` for ExecJS to call

The two sides connect through HTML data attributes: Ruby renders the div with component name and props, TypeScript picks them up and mounts React components.

## CI Matrix

- Ruby: 3.3, 3.4, 4.0
- React: 18, 19
- Linting: Rubocop (Ruby 4.0), ESLint, Prettier

## Conventions

- Uses Conventional Commits (`feat:`, `fix:`, `chore:`, etc.)
- Ruby strings use double quotes (enforced by Rubocop)
- TypeScript uses Prettier defaults except: no trailing commas, no single quotes, bracketSameLine
- Tests: Minitest for Ruby, Vitest with happy-dom for TypeScript
- Versions are synchronized across `lib/tombolo/version.rb` and `package.json` by release-please
