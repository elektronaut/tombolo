import { type ComponentType } from "react";
type ComponentMap = Record<string, ComponentType<Record<string, unknown>>>;
export declare function mount(components: ComponentMap, scope?: ParentNode): void;
export declare function unmount(scope?: ParentNode): void;
export declare function start(components: ComponentMap): void;
export {};
