import { type ComponentType } from "react";
type ComponentMap = Record<string, ComponentType<any>>;
export declare function registerServerRenderer(components: ComponentMap): void;
export {};
