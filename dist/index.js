import { createElement } from "react";
import { createRoot, hydrateRoot } from "react-dom/client";
const roots = new Map();
export function mount(components, scope = document) {
    const nodes = scope.querySelectorAll("[data-react-component]");
    for (const node of nodes) {
        if (roots.has(node))
            continue;
        const name = node.dataset.reactComponent;
        if (!name)
            continue;
        const component = components[name];
        if (!component) {
            console.warn(`Tombolo: Component "${name}" not found`);
            continue;
        }
        const props = node.dataset.reactProps
            ? JSON.parse(node.dataset.reactProps)
            : {};
        const element = createElement(component, props);
        if (node.hasAttribute("data-react-prerender")) {
            roots.set(node, hydrateRoot(node, element));
        }
        else {
            const root = createRoot(node);
            root.render(element);
            roots.set(node, root);
        }
    }
}
export function unmount(scope = document) {
    for (const [node, root] of roots) {
        if (scope.contains(node)) {
            root.unmount();
            roots.delete(node);
        }
    }
}
export function start(components) {
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", () => mount(components));
    }
    else {
        mount(components);
    }
}
