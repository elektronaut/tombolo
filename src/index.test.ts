import { describe, it, expect, vi, beforeEach } from "vitest";
import { createElement, type ComponentType } from "react";
import { mount, unmount, start } from "./index";

function Greeting({ name }: { name?: string }) {
  return createElement("span", null, `Hello ${name || "World"}`);
}

function Other() {
  return createElement("span", null, "Other");
}

const components: Record<string, ComponentType<Record<string, unknown>>> = {
  Greeting: Greeting as ComponentType<Record<string, unknown>>,
  Other: Other as ComponentType<Record<string, unknown>>
};

function addNode(
  name: string,
  props?: Record<string, unknown>,
  prerender = false
) {
  const div = document.createElement("div");
  div.dataset.reactComponent = name;
  if (props) {
    div.dataset.reactProps = JSON.stringify(props);
  }
  if (prerender) {
    div.setAttribute("data-react-prerender", "");
    div.innerHTML = `<span>Hello ${props?.name || "World"}</span>`;
  }
  document.body.appendChild(div);
  return div;
}

beforeEach(() => {
  document.body.innerHTML = "";
  unmount();
});

describe("mount", () => {
  it("renders a component into a [data-react-component] div", async () => {
    addNode("Greeting");
    mount(components);
    await vi.waitFor(() => {
      expect(document.body.textContent).toContain("Hello World");
    });
  });

  it("parses and passes props from data-react-props", async () => {
    addNode("Greeting", { name: "Tombolo" });
    mount(components);
    await vi.waitFor(() => {
      expect(document.body.textContent).toContain("Hello Tombolo");
    });
  });

  it("skips nodes that are already mounted", async () => {
    addNode("Greeting");
    mount(components);
    mount(components);
    await vi.waitFor(() => {
      const spans = document.querySelectorAll("span");
      expect(spans.length).toBe(1);
    });
  });

  it("warns on missing component", () => {
    const warn = vi.spyOn(console, "warn").mockImplementation(() => {});
    addNode("NonExistent");
    mount(components);
    expect(warn).toHaveBeenCalledWith(
      'Tombolo: Component "NonExistent" not found'
    );
    warn.mockRestore();
  });

  it("calls hydrateRoot when data-react-prerender attribute is present", async () => {
    const node = addNode("Greeting", { name: "SSR" }, true);
    mount(components);
    await vi.waitFor(() => {
      expect(node.textContent).toContain("Hello SSR");
    });
  });

  it("respects custom scope parameter", async () => {
    const scope = document.createElement("div");
    document.body.appendChild(scope);
    const inner = document.createElement("div");
    inner.dataset.reactComponent = "Greeting";
    scope.appendChild(inner);

    addNode("Other");

    mount(components, scope);

    await vi.waitFor(() => {
      expect(scope.textContent).toContain("Hello World");
    });

    // Other component outside scope should not be mounted
    const outerNode = document.querySelector(
      '[data-react-component="Other"]'
    ) as HTMLElement;
    expect(outerNode.textContent).toBe("");
  });
});

describe("unmount", () => {
  it("cleans up all mounted roots", async () => {
    addNode("Greeting");
    addNode("Other");
    mount(components);
    await vi.waitFor(() => {
      expect(document.body.textContent).toContain("Hello World");
    });
    unmount();
    await vi.waitFor(() => {
      expect(document.body.textContent).not.toContain("Hello World");
    });
  });

  it("respects custom scope parameter", async () => {
    const scope = document.createElement("div");
    document.body.appendChild(scope);
    const inner = document.createElement("div");
    inner.dataset.reactComponent = "Greeting";
    scope.appendChild(inner);

    const outer = addNode("Other");

    mount(components);

    await vi.waitFor(() => {
      expect(scope.textContent).toContain("Hello World");
      expect(outer.textContent).toContain("Other");
    });

    unmount(scope);

    await vi.waitFor(() => {
      expect(scope.textContent).not.toContain("Hello World");
    });
    // Other component outside scope should still be mounted
    expect(outer.textContent).toContain("Other");
  });
});

describe("start", () => {
  it("mounts components when DOM is already loaded", async () => {
    addNode("Greeting");
    start(components);
    await vi.waitFor(() => {
      expect(document.body.textContent).toContain("Hello World");
    });
  });
});
