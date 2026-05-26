document.addEventListener("DOMContentLoaded", () => {
  const typeOfAccess = document.getElementById("type-of-access");
  const groupsWrapper = document.getElementById("poll-groups-wrapper");

  if (!typeOfAccess || !groupsWrapper) {
    return;
  }

  const updateGroupsVisibility = () => {
    groupsWrapper.classList.toggle("d-none", typeOfAccess.value !== "GROUP");
  };

  typeOfAccess.addEventListener("change", updateGroupsVisibility);
  updateGroupsVisibility();
});
