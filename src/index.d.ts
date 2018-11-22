import * as React from 'react';

export interface OptionValue<T> {
  label: string;
  value: T;
}

export interface SimpleSelectEvent<T> {
  originalEvent: Event;
  value: OptionValue<T>;
  open: boolean;
}

export interface MultipleSelectEvent<T> {
  originalEvent: Event;
  values: OptionValue<T>[];
  open: boolean;
}

export interface SimpleSelectProps<T> {
  autofocus?: boolean;
  cancelKeyboardEventOnSelection?: boolean;
  className?: string;
  createFromSearch?(items: OptionValue<T>[], search: string): OptionValue<T>;
  defaultValue?: OptionValue<T>;
  delimiters?: [any];
  disabled?: boolean;
  dropdownDirection?: number;
  editable?(item: OptionValue<T>): string;
  filterOptions?(items: OptionValue<T>[], search: string): OptionValue<T>[];
  firstOptionIndexToHighlight?(index: number, items: OptionValue<T>[], item: OptionValue<T>, search: string): number;
  groupId?(item: OptionValue<T>): any;
  groups?: any[];
  groupsAsColumns?: boolean;
  hideResetButton?: boolean;
  highlightedUid?: any;
  name?: string;
  open?: boolean;
  onBlur?(event: SimpleSelectEvent<T>): void;
  onFocus?(event: SimpleSelectEvent<T>): void;
  onHighlightedUidChange?(uid: any): void;
  onKeyboardSelectionFailed?(keycode: number): void;
  onOpenChange?(open: boolean): void;
  onPaste?(event: SimpleSelectEvent<T>): void;
  onSearchChange?(search: string): void;
  onValueChange?(item: OptionValue<T>): void;
  options?: OptionValue<T>[];
  placeholder?: string;
  renderGroupTitle?(index: number, group: any): React.ReactElement<any>;
  renderNoResultsFound?(item: OptionValue<T>, search: string): React.ReactElement<any>;
  renderOption?(item: OptionValue<T>): React.ReactElement<any>;
  renderResetButton?(): React.ReactElement<any>;
  renderToggleButton?(options: {open: boolean, flipped: any}): React.ReactElement<any>;
  renderValue?(item: OptionValue<T>): React.ReactElement<any>;
  restoreOnBackspace?(item: OptionValue<T>): string;
  search?: string;
  serialize?(item: OptionValue<T>): string;
  style?: any;
  tether?: boolean;
  'tether-props'?: any;
  theme?: string;
  transitionEnter?: boolean;
  transitionEnterTimeout?: number;
  transitionLeave?: boolean;
  transitionLeaveTimeout?: number;
  uid?(item: OptionValue<T>): any;
  value?: OptionValue<T>;
  valueFromPaste?(options: OptionValue<T>[], value: OptionValue<T>, pastedText: string): OptionValue<T>;
}

declare class SimpleSelect<T> extends React.Component<SimpleSelectProps<T>, any> {
  
}

export interface MultiSelectProps<T> extends SimpleSelectProps<T> {
  anchor?: OptionValue<T>;
  createFromSearch?(items: OptionValue<T>[], search: string): OptionValue<T>;
  createFromSearch?(options: OptionValue<T>[], values: OptionValue<T>[], search: string): OptionValue<T>;
  defaultValues?: OptionValue<T>[];
  filterOptions?(items: OptionValue<T>[], search: string): OptionValue<T>[];
  filterOptions?(options: OptionValue<T>[], values: OptionValue<T>[], search: string): OptionValue<T>[];
  onAnchorChange?(item: OptionValue<T>): void;
  onBlur?(event: SimpleSelectEvent<T>): void;
  onBlur?(event: MultipleSelectEvent<T>): void;
  onFocus?(event: SimpleSelectEvent<T>): void;
  onFocus?(event: MultipleSelectEvent<T>): void;
  onValuesChange?(item: OptionValue<T>): void;
  maxValues?: number;
  closeOnSelect?: boolean;
  valuesFromPaste?(options: OptionValue<T>[], values: OptionValue<T>[], pastedText: string): OptionValue<T>[];
}

declare class MultiSelect<T> extends React.Component<MultiSelectProps<T>, any> {
  
}