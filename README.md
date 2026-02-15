# Tombolo

Minimal React component mounting for Rails, inspired by
[react-rails](https://github.com/reactjs/react-rails).

Tombolo is designed for modern Rails apps using jsbundling-rails and
propshaft. It provides a `react_component` view helper and optional
server-side rendering with no asset pipeline integration — just a component
map and a few lines of JavaScript.

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

Run the install generator to create a config initializer and SSR entry
point:

```sh
bin/rails generate tombolo:install
```

## Usage

### Rails helper

Render a React component from any view or partial:

```erb
<%= react_component("Greeting", props: { name: "World" }) %>
```

### Client-side mounting

Tombolo takes a component map — an object mapping component names to React
components. The easiest way to create one is a barrel file that re-exports
your components:

```typescript
// app/javascript/components/index.ts
export { Greeting } from "./Greeting";
export { SearchForm } from "./SearchForm";
```

Import it and call `Tombolo.start` to mount components on page load:

```typescript
import * as Tombolo from "tombolo";
import * as components from "./components";

Tombolo.start(components);
```

Both `Tombolo.mount` and `Tombolo.unmount` accept an optional `scope`
parameter to limit operations to a subtree of the DOM:

```typescript
Tombolo.mount(components, document.getElementById("sidebar"));
```

#### Turbo

For apps using Turbo, use `Tombolo.mount` and `Tombolo.unmount` directly:

```typescript
import * as Tombolo from "tombolo";
import * as components from "./components";

document.addEventListener("turbo:load", () => Tombolo.mount(components));
document.addEventListener("turbo:before-cache", () => Tombolo.unmount());
```

### Server-side rendering

Create a server entry point that registers your components:

```typescript
// app/javascript/prerender.ts
import { registerServerRenderer } from "tombolo/server";
import * as components from "./components";

registerServerRenderer(components);
```

Build it with esbuild (or your bundler of choice) targeting a CommonJS
output that ExecJS can evaluate.

Then use `prerender: true` in your views:

```erb
<%= react_component("Greeting", props: { name: "World" }, prerender: true) %>
```

The default server bundle path is `app/assets/builds/prerender.js`. To
customize it, add an initializer:

```ruby
# config/initializers/tombolo.rb
Tombolo.configure do |config|
  config.server_bundle = "path/to/your/bundle.js"
end
```

## API Reference

### npm

#### `Tombolo.start(components)`

Calls `mount` on `DOMContentLoaded`, or immediately if the DOM is already
loaded. Convenience function for apps without Turbo.

#### `Tombolo.mount(components, scope?)`

Scans `scope` (default: `document`) for elements with a
`data-react-component` attribute. For each element, looks up the component
by name, parses props from `data-react-props`, and mounts it.
Already-mounted elements are skipped. Missing components log a warning to
the console.

#### `Tombolo.unmount(scope?)`

Unmounts all tracked React roots within `scope` (default: `document`).

#### `registerServerRenderer(components)`

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

- `config.camelize_props` — Convert snake_case prop keys to camelCase.
  Default: `false`
- `config.server_bundle` — Path to the server-side JS bundle for SSR.
  Default: `"app/assets/builds/prerender.js"`

## Migrating from react-rails

The main difference is the helper signature. react-rails passes props as a
positional argument, Tombolo uses a keyword argument:

```ruby
# react-rails
react_component("Name", { title: "Hello" })

# Tombolo
react_component("Name", props: { title: "Hello" })
```

## License

MIT
