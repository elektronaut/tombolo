import { createElement, type ComponentType } from "react";
import { createRoot, hydrateRoot, type Root } from "react-dom/client";

type ComponentMap = Record<string, ComponentType<Record<string, unknown>>>;

const roots = new Map<Element, Root>();

export function mount(components: ComponentMap, scope: ParentNode = document) {
  const nodes = scope.querySelectorAll<HTMLElement>("[data-react-component]");

  for (const node of nodes) {
    if (roots.has(node)) continue;

    const name = node.dataset.reactComponent;
    if (!name) continue;

    const component = components[name];
    if (!component) {
      console.warn(`Tombolo: Component "${name}" not found`);
      continue;
    }

    const props = node.dataset.reactProps
      ? (JSON.parse(node.dataset.reactProps) as Record<string, unknown>)
      : {};

    const element = createElement(component, props);

    if (node.hasAttribute("data-react-prerender")) {
      roots.set(node, hydrateRoot(node, element));
    } else {
      const root = createRoot(node);
      root.render(element);
      roots.set(node, root);
    }
  }
}

export function unmount(scope: ParentNode = document) {
  for (const [node, root] of roots) {
    if (scope.contains(node)) {
      root.unmount();
      roots.delete(node);
    }
  }
}

export function start(components: ComponentMap) {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => mount(components));
  } else {
    mount(components);
  }
}
