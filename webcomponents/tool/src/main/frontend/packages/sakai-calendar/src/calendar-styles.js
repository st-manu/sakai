import { css } from "lit";

export const calendarStyles = css`
  #site-filter {
    margin-bottom: 0;
  }

  .calendar {
    display: flex;
    flex-direction: column;
  }

  .calendar__chrome {
    display: flex;
    flex-direction: column;
    flex: 0 0 auto;
  }

  .calendar__chrome.dashboard {
    background-color: var(--sakai-dashboard-widget-secondary-bg-color);
  }

  .calendar__navigation-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
    align-items: center;
    gap: var(--sakai-space-2) var(--sakai-space-3);
    box-sizing: border-box;
    padding: var(--sakai-space-2) 0;
    min-height: 2.5rem;
  }

  .calendar__chrome.dashboard .calendar__navigation-row {
    border-top: 1px solid var(--sakai-border-color);
    padding: var(--sakai-space-2);
  }

  .calendar__navigation {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: flex-start;
    gap: var(--sakai-space-2) var(--sakai-space-4);
    min-width: 0;
    padding: 0;
  }

  .calendar__navigation-heading {
    margin: 0;
    font-size: var(--sakai-font-size-sm);
    font-weight: 700;
    line-height: 1.2;
  }

  .calendar__chrome.dashboard .calendar__navigation-heading {
    font-size: var(--sakai-font-size-sm);
  }

  .calendar__navigation__year,
  .calendar__navigation__month {
    display: inline-flex;
    align-items: center;
    gap: var(--sakai-space-1);
  }

  .calendar__previous-button,
  .calendar__next-button {
    min-width: unset;
    min-height: unset;
    padding: var(--sakai-space-1) var(--sakai-space-2);
    border: 1px solid var(--sakai-border-color);
    border-radius: var(--sakai-radius-sm);
    background-color: var(--sakai-background-color-1);
    color: var(--sakai-text-color-2);
    font-size: var(--sakai-font-size-sm);
    font-weight: 700;
    line-height: 1.2;
    cursor: pointer;

    &:hover:not(:disabled) {
      background-color: var(--sakai-background-color-2);
    }

    &:focus-visible {
      outline: 2px solid var(--focus-outline-color);
      outline-offset: 1px;
    }

    &:disabled {
      background-color: var(--button-disabled-background);
      color: var(--button-disabled-text-color);
      cursor: not-allowed;
    }
  }

  .calendar__chrome.dashboard .calendar__previous-button,
  .calendar__chrome.dashboard .calendar__next-button {
    padding: 0.15rem var(--sakai-space-1);
    font-size: var(--sakai-font-size-xs);
  }

  .calendar__today-button {
    justify-self: end;
    margin: 0;
    padding: 0;
    border: 0;
    background: none;
    color: var(--link-color);
    font-size: var(--sakai-font-size-sm);
    font-weight: 600;
    white-space: nowrap;
    cursor: pointer;

    &:hover {
      text-decoration: underline;
    }

    &:focus-visible {
      outline: 2px solid var(--focus-outline-color);
      outline-offset: 2px;
    }
  }

  .calendar__chrome.dashboard .calendar__today-button {
    font-size: var(--sakai-font-size-xs);
  }

  #widget-status {
    display: flex;
    align-items: center;
    justify-content: center;
    flex: 0 0 auto;
    box-sizing: border-box;
    padding: var(--sakai-space-1) var(--sakai-space-3);
    min-height: 2.5rem;
    border-top: 1px solid var(--sakai-border-color);
    background-color: var(--sakai-dashboard-widget-secondary-bg-color);
    color: var(--sakai-text-color-2);
    font-size: var(--sakai-font-size-xs);
    line-height: 1.3;
    text-align: center;
  }

  .calendar__chrome:not(.dashboard) #widget-status {
    padding: var(--sakai-space-2) 0;
    border: 0;
    background: transparent;
    font-size: var(--sakai-font-size-sm);
  }

  #days-events {
    margin-top: var(--sakai-space-2);
  }

  #days-events.dashboard-events {
    display: flex;
    flex-direction: column;
    margin-top: 0;
    padding: 0;
    border-top: 1px solid var(--sakai-border-color);
    box-sizing: border-box;
    min-height: 0;
    overflow: hidden;
  }

  .calendar__expand-toggle {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: var(--sakai-space-1);
    flex: 0 0 auto;
    width: 100%;
    margin: 0;
    box-sizing: border-box;
    padding: var(--sakai-space-1) var(--sakai-space-3);
    min-height: 2.5rem;
    border: 0;
    border-bottom: 1px solid var(--sakai-border-color);
    background-color: var(--sakai-dashboard-widget-secondary-bg-color);
    color: var(--sakai-text-color-2);
    font-size: var(--sakai-font-size-xs);
    font-weight: 600;
    line-height: 1.3;
    text-align: center;
    cursor: pointer;

    &:hover:not(:disabled) {
      color: var(--sakai-text-color-1);
    }

    &:disabled {
      opacity: 0.85;
      cursor: default;
    }
  }

  #days-events.dashboard-events .dashboard-events-body {
    flex: 1 1 auto;
    min-height: 0;
    overflow: auto;
    padding: var(--sakai-space-2) var(--sakai-space-3);
    box-sizing: border-box;
  }

  #days-events sakai-icon {
    flex: 0 0 auto;
    margin-inline-end: var(--sakai-space-2);
  }

  #days-events-title {
    margin-bottom: var(--sakai-space-2);
    font-weight: 700;
  }

  #days-events.dashboard-events #days-events-title {
    margin-bottom: var(--sakai-space-1);
    font-size: var(--sakai-font-size-xs);
  }

  #days-events a {
    color: var(--link-color);
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }

  .dashboard-event-row {
    display: flex;
    align-items: flex-start;
    gap: var(--sakai-space-1);
    margin-bottom: var(--sakai-space-1);
    font-size: var(--sakai-font-size-xs);
    line-height: 1.35;
  }

  .dashboard-events-empty {
    color: var(--sakai-text-color-2);
    font-size: var(--sakai-font-size-xs);
  }

  .calendar__grid tbody tr[hidden] {
    display: none;
  }

  .calendar__weekday-header {
    padding-top: var(--sakai-space-2);
    text-align: center;
  }

  .calendar__previous-month-button,
  .calendar__next-month-button,
  .calendar__day-button {
    background-color: var(--sakai-calendar-button-background-color);
    color: var(--sakai-calendar-button-color);
    font-weight: 500;
  }

  .calendar__day-button[today] {
    background-color: var(--sakai-calendar-today-bg-color);
    color: var(--sakai-calendar-today-color);
    border-radius: 50%;
    font-weight: 700;
    text-decoration: none;
  }

  .calendar__day-button[selected] {
    background-color: transparent;
    color: var(--sakai-calendar-button-color, var(--sakai-text-color-1));
    outline: 2px solid var(--sakai-calendar-today-bg-color);
    outline-offset: 2px;
    border-radius: 50%;
    font-weight: 700;
  }

  .has-events,
  .has-events[selected],
  .has-events[next-month],
  .has-events[previous-month] {
    background-color: var(--sakai-calendar-has-events-bg-color);
    color: var(--sakai-calendar-has-events-fg-color);
    border-radius: 50%;
    font-weight: 700;
  }

  .has-events.deadline,
  .has-events.deadline[next-month],
  .has-events.deadline[previous-month] {
    background-color: var(--sakai-calendar-deadline-bg-color);
    color: var(--sakai-calendar-deadline-fg-color);
  }

  .has-events[today],
  .calendar__day-button[today][selected] {
    background-color: var(--sakai-calendar-today-bg-color);
    color: var(--sakai-calendar-today-color);
  }

  .has-events.deadline[today],
  .has-events.deadline[selected] {
    box-shadow: inset 0 0 0 2px var(--sakai-calendar-deadline-bg-color);
  }

  .calendar__day-button:hover {
    border-color: var(--sakai-border-color);
  }

  .calendar__day-button[disabled],
  .calendar__day-button[aria-disabled="true"] {
    background-color: var(--sakai-calendar-button-disabled-bg-color, transparent);
    color: var(--sakai-calendar-button-disabled-color);
  }
`;
