import { describe, it, expect, beforeEach } from "vitest";
import { createElement } from "react";
import { registerServerRenderer } from "./server";
import type { ComponentType } from "react";

function Greeting({ name }: { name?: string }) {
  return createElement("span", null, `Hello ${name || "World"}`);
}

const components: Record<string, ComponentType<Record<string, unknown>>> = {
  Greeting: Greeting as ComponentType<Record<string, unknown>>
};

beforeEach(() => {
  delete (globalThis as Record<string, unknown>).renderComponent;
});

describe("registerServerRenderer", () => {
  it("assigns renderComponent to globalThis", () => {
    registerServerRenderer(components);
    expect(
      (globalThis as Record<string, unknown>).renderComponent
    ).toBeDefined();
  });

  it("returns rendered HTML string", () => {
    registerServerRenderer(components);
    const render = (globalThis as Record<string, unknown>).renderComponent as (
      name: string,
      propsJson: string
    ) => string;
    const html = render("Greeting", JSON.stringify({ name: "Tombolo" }));
    expect(html).toContain("Hello Tombolo");
    expect(html).toContain("<span>");
  });

  it("throws on missing component", () => {
    registerServerRenderer(components);
    const render = (globalThis as Record<string, unknown>).renderComponent as (
      name: string,
      propsJson: string
    ) => string;
    expect(() => render("Missing", "{}")).toThrow(
      'Tombolo: Component "Missing" not found'
    );
  });
});
