document.addEventListener("DOMContentLoaded", () => {
  const typeOfAccess = document.getElementById("type-of-access");
  const groupsWrapper = document.getElementById("poll-groups-wrapper");

  if (!typeOfAccess || !groupsWrapper) {
    return;
  }

  const updateGroupsVisibility = () => {
    const isGroupAccess = typeOfAccess.value === "GROUP";
    groupsWrapper.classList.toggle("sakai-polls-is-hidden", !isGroupAccess);
    groupsWrapper.querySelectorAll("input[type=checkbox]").forEach(input => {
      input.disabled = !isGroupAccess;
    });
  };

  typeOfAccess.addEventListener("change", updateGroupsVisibility);
  updateGroupsVisibility();
});
