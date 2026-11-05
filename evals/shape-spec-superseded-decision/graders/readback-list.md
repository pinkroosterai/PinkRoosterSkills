---
type: llm
---
PASS if the reply says the next readback lists only the assumed Depends on entry, and that the superseded polling entry is history that is neither counted nor read back again.
FAIL if it counts the superseded entry, lists it or the confirmed webhooks entry for readback, or gives a Confirmed line other than 1/2 decisions with 1 assumed, unconfirmed.
