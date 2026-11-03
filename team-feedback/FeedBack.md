# Dungeon Deck — Team Feedback

## Purpose

This folder is dedicated to collecting feedback, suggestions, and requested changes from our teammates regarding the UI, gameplay interactions, and overall functionality of Dungeon Deck.

As Role 3 (UI/UX & Mobile Development), our goal is to make sure the features we've implemented work correctly with the combat, card, and dungeon systems developed by the other roles.

We will use the feedback provided here to identify problems, make improvements, and adjust our work on the `feature/ui-development` branch.

## Important: Identify Who Is Giving Feedback

**Every feedback submission must identify the person and role providing the feedback.**

Please include:

- **Name:** The teammate submitting the feedback.
- **Role:** Role 1, Role 2, Role 3, or Role 4.
- **Date:** When the feedback was submitted.
- **Feature:** The system or feature being discussed.

This is required so we know who suggested each change, which role it affects, and who to contact if we need clarification.

If multiple teammates contribute suggestions, please identify each contributor separately.

## What We Need From Our Teammates

Please test the current version of Dungeon Deck on the `feature/ui-development` branch and provide feedback on anything that needs to be fixed, changed, or improved.

We are especially interested in:

- **Bugs:** Features that don't work correctly or produce errors.
- **UI improvements:** Suggestions involving menus, buttons, card displays, or combat information.
- **Gameplay feedback:** Card drawing, manual discarding, combat difficulty, or other interactions.
- **Integration problems:** Issues between the UI and systems developed by other roles.
- **Feature requests:** Changes that could improve usability or the overall player experience.
- **Mobile compatibility:** Problems with layout, responsiveness, or controls on mobile devices.

Please be specific about what you want changed and why.

## How to Submit Feedback

Each teammate should create their own Markdown feedback file inside this folder.

Suggested filenames:

- `role1-feedback.md`
- `role2-feedback.md`
- `role4-feedback.md`

If multiple teammates share a role, include their name in the filename to avoid overwriting someone else's feedback.

Each feedback file should use the following format.

### Feedback Submission Template

**Submitted By:** [Your name]

**Role:** [Your role number and responsibility]

**Date:** [Submission date]

**Feature or System:** [What part of Dungeon Deck are you reviewing?]

**Problem or Suggested Change:**

[Explain what needs to be fixed, changed, or improved.]

**Reason for the Change:**

[Explain why you think the change is necessary.]

**Expected Result:**

[Describe how the feature should work after the change.]

**Additional Notes (Optional):**

[Include error messages, screenshots, testing observations, or other suggestions.]

---

## Example Feedback Submission

**Submitted By:** Example Teammate

**Role:** Role 1 — Combat Systems

**Date:** October 27, 2026

**Feature or System:** Combat HUD — Enemy Intent Display

**Problem or Suggested Change:**

The enemy's next attack should be more noticeable during combat.

**Reason for the Change:**

Players may have difficulty recognizing how much damage an enemy is about to deal.

**Expected Result:**

The Combat HUD should display enemy attack intentions more clearly so players can make better decisions before ending their turn.

**Additional Notes:**

Consider improving the text formatting or adding a visual indicator.

---

## What Happens After Feedback Is Submitted?

Once feedback has been submitted, Role 3 will:

1. Review the feedback and identify who submitted it.
2. Determine which feature or system needs changes.
3. Contact the teammate who submitted the feedback if clarification is needed.
4. Discuss changes that may affect other roles' systems.
5. Implement agreed improvements on the `feature/ui-development` branch.
6. Test the changes to ensure they work correctly.
7. Ask the original teammate to review the changes if necessary.

## Feedback Status

We may use the following statuses to track suggestions:

| Status | Meaning |
|---|---|
| Pending | Feedback has been submitted but not reviewed. |
| Under Review | We are evaluating the suggested change. |
| In Progress | We are implementing the change. |
| Completed | The change has been implemented and tested. |
| Needs Discussion | We need clarification or agreement from the team. |
| Declined | The change will not be implemented, with an explanation. |

## Final Note

**Please always include your name and role with your feedback. Anonymous or unidentified suggestions may require clarification before we can act on them.**

The purpose of this folder is to improve communication between roles and make sure Dungeon Deck works as one complete game.

Our goal is to use everyone's feedback to improve the project before merging changes into `main`.
