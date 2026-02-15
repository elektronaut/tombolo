import { createElement, type ComponentType } from "react";
import { renderToString } from "react-dom/server";

type ComponentMap = Record<string, ComponentType<Record<string, unknown>>>;

declare let globalThis: Record<string, unknown>;

export function registerServerRenderer(components: ComponentMap) {
  globalThis.renderComponent = (name: string, propsJson: string): string => {
    const component = components[name];
    if (!component) {
      throw new Error(`Tombolo: Component "${name}" not found`);
    }

    const props = JSON.parse(propsJson) as Record<string, unknown>;
    return renderToString(createElement(component, props));
  };
}
