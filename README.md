# Tombolo

[![Gem Version](https://badge.fury.io/rb/tombolo.svg)](https://badge.fury.io/rb/tombolo)
[![npm](https://img.shields.io/npm/v/tombolo)](https://www.npmjs.com/package/tombolo)
[![CI](https://github.com/elektronaut/tombolo/actions/workflows/build.yml/badge.svg)](https://github.com/elektronaut/tombolo/actions/workflows/build.yml)
[![MIT License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Tombolo is a lightweight alternative to
[react-rails](https://github.com/reactjs/react-rails) for mounting React
[islands](https://www.patterns.dev/posts/islands-architecture) in your Rails
views. It provides a `react_component` view helper, client-side mounting via a
component map, and optional server-side rendering through ExecJS.

Built for React 18+, Tombolo targets modern Rails apps using
[jsbundling-rails](https://github.com/rails/jsbundling-rails) (or any JS
bundler) and [propshaft](https://github.com/rails/propshaft), with no asset
pipeline integration — just register your components and write a few lines of
JavaScript.

## Compatibility

| Dependency | Versions |
|------------|----------|
| Ruby       | >= 3.2   |
| Rails      | >= 7.0   |
| React      | 18, 19   |

## Installation

Add the gem to your Gemfile:

```ruby
gem "tombolo"
# gem "execjs"  # required for server-side rendering
```

Install the npm package:

```sh
npm install tombolo
# or
pnpm add tombolo
```

Optionally, run the install generator to create a config initializer
(`config/initializers/tombolo.rb`) and an SSR entry point
(`app/javascript/prerender.ts`):

```sh
bin/rails generate tombolo:install
```

## Usage

### Rails helper

Render a React component from any view or partial:

```erb
<%= react_component("Greeting", props: { name: "World" }) %>
```

This renders a `<div>` with `data-react-component` and `data-react-props`
attributes that the JavaScript side picks up.

### Client-side mounting

Tombolo takes a component map — an object mapping component names to React
components. The easiest way to create one is a barrel file (a module that
re-exports from other modules):

```typescript
// app/javascript/components/index.ts
export { Greeting } from "./Greeting";
export { SearchForm } from "./SearchForm";
```

#### With Turbo

For apps using Turbo, use `Tombolo.mount` and `Tombolo.unmount` directly:

```typescript
import * as Tombolo from "tombolo";
import * as components from "./components";

document.addEventListener("turbo:load", () => Tombolo.mount(components));
document.addEventListener("turbo:before-cache", () => Tombolo.unmount());
```

#### Without Turbo

For apps without Turbo, `Tombolo.start` mounts components on
`DOMContentLoaded` (or immediately if the DOM is already loaded):

```typescript
import * as Tombolo from "tombolo";
import * as components from "./components";

Tombolo.start(components);
```

#### Scoped mounting

Both `Tombolo.mount` and `Tombolo.unmount` accept an optional `scope`
parameter to limit operations to a subtree of the DOM:

```typescript
Tombolo.mount(components, document.getElementById("sidebar"));
```

### Server-side rendering

SSR is optional and requires the [execjs](https://github.com/rails/execjs)
gem.

Create a server entry point that registers your components:

```typescript
// app/javascript/prerender.ts
import { registerServerRenderer } from "tombolo/server";
import * as components from "./components";

registerServerRenderer(components);
```

Build it with esbuild (or your bundler of choice) as a CommonJS bundle that
ExecJS can evaluate:

```sh
esbuild app/javascript/prerender.ts --bundle --platform=neutral --outfile=app/assets/builds/prerender.js
```

Then use `prerender: true` in your views:

```erb
<%= react_component("Greeting", props: { name: "World" }, prerender: true) %>
```

When a component is prerendered, the server-rendered HTML is placed inside the
div and Tombolo uses `hydrateRoot` instead of `createRoot` on the client.
This preserves interactivity without a full re-render.

The default server bundle path is `app/assets/builds/prerender.js`. To
customize it, add an initializer:

```ruby
# config/initializers/tombolo.rb
Tombolo.configure do |config|
  config.server_bundle = "path/to/your/bundle.js"
end
```

## Configuration

```ruby
Tombolo.configure do |config|
  # Convert snake_case prop keys to camelCase (default: false)
  config.camelize_props = true

  # Path to the server-side JS bundle for SSR
  # (default: "app/assets/builds/prerender.js")
  config.server_bundle = "app/assets/builds/prerender.js"
end
```

`camelize_props` can also be overridden per-call:

```erb
<%= react_component("Greeting", props: { first_name: "World" }, camelize_props: true) %>
```

## API reference

### JavaScript

#### `mount(components, scope?)`

Scans `scope` (default: `document`) for elements with a
`data-react-component` attribute. For each element, looks up the component by
name, parses props from `data-react-props`, and mounts it. Elements with a
`data-react-prerender` attribute are hydrated with `hydrateRoot`; all others
use `createRoot`. Already-mounted elements are skipped.

#### `unmount(scope?)`

Unmounts all tracked React roots within `scope` (default: `document`).

#### `start(components)`

Calls `mount` on `DOMContentLoaded`, or immediately if the DOM is already
loaded.

#### `registerServerRenderer(components)`

*Imported from `tombolo/server`.*

Assigns a `renderComponent(name, propsJson)` function to `globalThis`,
making it callable from ExecJS. Used in server entry points for SSR.

### Ruby

#### `react_component(name, props: {}, prerender: false, camelize_props: nil)`

Renders a `<div>` with `data-react-component` and `data-react-props`
attributes. When `prerender: true`, the component is rendered on the server
via ExecJS and the HTML is placed inside the div. Pass `camelize_props: true`
to convert snake_case prop keys to camelCase, or set it globally in the
configuration.

#### `Tombolo.configure { |config| ... }`

See [Configuration](#configuration) above.

## Migrating from react-rails

**Helper signature.** react-rails passes props as a positional argument,
Tombolo uses a keyword argument:

```ruby
# react-rails
react_component("Name", { title: "Hello" })

# Tombolo
react_component("Name", props: { title: "Hello" })
```

**No html_options argument.** react-rails accepts a third argument for HTML
attributes on the wrapper div. Tombolo does not support this — wrap the helper
call in your own tag if you need custom attributes.

**No asset pipeline integration.** Tombolo does not ship a component generator
or integrate with Sprockets/Webpacker. You manage your JavaScript build
yourself with jsbundling-rails or an equivalent.

**SSR setup.** Replace any `server_rendering.js` pack with a
`prerender.ts` entry point that calls `registerServerRenderer`. See
[Server-side rendering](#server-side-rendering) above.

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/elektronaut/tombolo).

## License

MIT
