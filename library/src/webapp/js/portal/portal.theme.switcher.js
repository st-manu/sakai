var portal = portal || {};

portal.darkThemeSwitcher = document.getElementById("sakai-dark-theme-switcher");

portal.defaultThemeClass = 'sakaiUserTheme-notSet';
portal.lightThemeClass = 'sakaiUserTheme-light';
portal.darkThemeClass = 'sakaiUserTheme-dark';

portal.syncBootstrapColorMode = themeClass => {
  const mode = themeClass === portal.darkThemeClass ? 'dark' : 'light';
  document.documentElement.setAttribute('data-bs-theme', mode);
  document.querySelectorAll('iframe').forEach(iframe => {
    if (iframe.contentDocument?.documentElement) {
      iframe.contentDocument.documentElement.setAttribute('data-bs-theme', mode);
    }
  });
};

portal.toggleDarkTheme = () => {
  // toggle the dark theme switch to the opposite state
  portal.darkThemeSwitcher && portal.darkThemeSwitcher.getAttribute("aria-checked") === "false" ? portal.enableDarkTheme() : portal.enableLightTheme();
  portal.setPortalThemeUserPref(portal.getCurrentThemeClass());
};

portal.setDarkThemeSwitcherToggle = onOff => {
  portal.darkThemeSwitcher?.setAttribute("aria-checked", onOff.toString());
};

portal.addCssClassToMarkup = themeClass => document.documentElement.classList.add(themeClass);

portal.removeCssClassFromMarkup = themeClass => document.documentElement.classList.remove(themeClass);

portal.isOsDarkThemeSet = () => window.matchMedia('(prefers-color-scheme: dark)').matches;

portal.setPortalThemeUserPref = theme => {

  const url = `/direct/userPrefs/updateKey/${portal.user.id}/sakai:portal:theme?theme=${theme}`;
  fetch(url, { method: "PUT", credentials: "include" })
  .then(r => {

    if (!r.ok) {
      throw new Error(`Network error while updating theme pref at ${url}`);
    } 
  })
  .catch (error => console.error(error));
};


portal.getCurrentThemeClass = () => {

  if (document.documentElement.classList.contains(portal.darkThemeClass)) {
    return portal.darkThemeClass;
  } else if (document.documentElement.classList.contains(portal.lightThemeClass)) {
    return portal.lightThemeClass;
  }
  return portal.defaultThemeClass;
};

portal.updateIframeTheme = () => {

  const themeClass = portal.getCurrentThemeClass();
  document.querySelectorAll('iframe').forEach(iframe => {
    if (iframe.contentDocument?.documentElement) {
      iframe.contentDocument.documentElement.classList.remove(portal.defaultThemeClass, portal.lightThemeClass, portal.darkThemeClass);
      iframe.contentDocument.documentElement.classList.add(themeClass);
    }
  });
  portal.syncBootstrapColorMode(themeClass);
};

document.addEventListener('DOMContentLoaded', () => {

  document.querySelectorAll('iframe').forEach(iframe => {
    iframe.addEventListener('load', portal.updateIframeTheme);
  });
  portal.updateIframeTheme();
});



portal.enableDarkTheme = () => {

  portal.setDarkThemeSwitcherToggle(true);
  portal.removeCssClassFromMarkup(portal.defaultThemeClass);
  portal.removeCssClassFromMarkup(portal.lightThemeClass);
  portal.addCssClassToMarkup(portal.darkThemeClass);
  portal.syncBootstrapColorMode(portal.darkThemeClass);
  portal.updateIframeTheme();
  if (portal.darkThemeSwitcher) {
    portal.darkThemeSwitcher.title = portal.i18n.theme_switch_to_light;
  }
};

portal.enableLightTheme = () => {

  portal.setDarkThemeSwitcherToggle(false);
  portal.removeCssClassFromMarkup(portal.defaultThemeClass);
  portal.removeCssClassFromMarkup(portal.darkThemeClass);
  portal.addCssClassToMarkup(portal.lightThemeClass);
  portal.syncBootstrapColorMode(portal.lightThemeClass);
  portal.updateIframeTheme();
  if (portal.darkThemeSwitcher) {
    portal.darkThemeSwitcher.title = portal.i18n.theme_switch_to_dark;
  }
};


// if the dark theme switch is on the page, attach listener to dark theme toggle switch
portal.darkThemeSwitcher?.addEventListener('click', portal.toggleDarkTheme, false);

if (portal.userThemeAutoDetectDark) {

  if (portal.user.id) {
    // only check for unset theme preference because light and dark themes are already set by Java
    if (portal.userTheme === portal.defaultThemeClass) {
      // if the user has dark mode set on their OS, enable dark mode
      portal.isOsDarkThemeSet() ? portal.enableDarkTheme() : portal.enableLightTheme();
    }
  } else if (portal.isOsDarkThemeSet()) {
    // just add the dark theme to the markup if not logged in and the user has dark mode set on their OS (no prefs to save)
    portal.addCssClassToMarkup(portal.darkThemeClass);
  }
}

if (document.documentElement.classList.contains(portal.darkThemeClass)) {
  // the dark theme switch toggle is off by default, so toggle it to on if dark theme is enabled
  portal.setDarkThemeSwitcherToggle(true);
}

// Align Bootstrap 5.3 color mode with current Sakai theme class
portal.syncBootstrapColorMode(portal.getCurrentThemeClass());

portal.getCurrentSetTheme = async () => {
  
  const userId = localStorage.getItem('last-sakai-user');
  if (!userId) return portal.isOsDarkThemeSet() ? portal.darkThemeClass : portal.lightThemeClass;

  const url = `/direct/userPrefs/key/${userId}/sakai:portal:theme.json`;
  
  try {
    const response = await fetch(url, {
      credentials: "include",
      headers: { 'Cache-Control': 'no-cache', 'Pragma': 'no-cache' }
    });
    if (!response.ok) throw new Error(`Network error when fetching from ${url}`);
    
    const { data } = await response.json();
    return data?.theme || (portal.isOsDarkThemeSet() ? portal.darkThemeClass : portal.lightThemeClass);
  } catch (error) {
    console.error(`${error.message}. Using OS theme preference.`);
    return portal.isOsDarkThemeSet() ? portal.darkThemeClass : portal.lightThemeClass;
  }
};
