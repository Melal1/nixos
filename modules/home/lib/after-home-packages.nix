# Preserve the former user-profile-before-system-profile ordering when ordinary
# system package lists join HM. Keep relative priorities (e.g. Python/Quickshell)
# instead of setting every relocated package to the same lowPrio value.
lib: map (package: lib.setPrio (100 + (package.meta.priority or lib.meta.defaultPriority)) package)
