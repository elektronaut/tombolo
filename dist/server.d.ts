import { type ComponentType } from "react";
type ComponentMap = Record<string, ComponentType<Record<string, unknown>>>;
export declare function registerServerRenderer(components: ComponentMap): void;
export {};
