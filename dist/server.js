import { createElement } from "react";
import { renderToString } from "react-dom/server";
export function registerServerRenderer(components) {
    globalThis.renderComponent = (name, propsJson) => {
        const component = components[name];
        if (!component) {
            throw new Error(`Tombolo: Component "${name}" not found`);
        }
        const props = JSON.parse(propsJson);
        return renderToString(createElement(component, props));
    };
}
