# Visible Requirements

## Goal

Fix a USB disconnect or probe-remove refcount bug so repeated attach and detach cycles no longer trigger the visible failure.

## Constraints

- preserve normal attach and detach behavior
- keep the patch local to the lifecycle and cleanup path
- avoid turning the task into a broad subsystem rewrite

## Public Pass Conditions

1. the target kernel or module builds successfully
2. the public disconnect stress repro no longer triggers the visible failure
3. normal attach and detach behavior still works

## Expected Working Set

- disconnect handling
- probe and remove lifecycle
- nearby refcounting helpers
- cleanup and release paths

## Hackathon Scope

This task is the kernel fallback for the 24-hour MVP. Use it only if `k_ioctl_bounds_guard` proves too broad or too flaky.
