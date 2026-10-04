# Example end-to-end request (Assignment 1)

## Setup check

- All three bots in one Telegram group
- Group Privacy **OFF** for each bot (BotFather)
- Three gateways running (`start_gateways.ps1`)

Replace `@mdl_coord_bot`, `@mdl_research_bot`, `@mdl_coder_bot` with your real usernames.

---

## Request A (human mentions only coordinator)

```text
@mdl_coord_bot I need a short study note on scaled dot-product attention.
Please have the researcher find the original paper and summarise it,
and have the coder show a tiny PyTorch example. Then give me a Final answer.
```

### Expected flow

1. Coordinator acknowledges and @mentions researcher + coder with clear briefs  
2. Researcher posts arXiv link + bullets  
3. Coder posts a small code snippet  
4. Coordinator posts **Final answer** synthesizing both  

---

## Request B (human pre-tags specialists — still coordinator-led)

```text
@mdl_coord_bot Explain backprop in 5 sentences for someone shaky on it.
@mdl_research_bot find one good primary/tutorial source.
@mdl_coder_bot show a 10-line autograd toy example.
```

---

## Failure demo (for defense Q4)

Try with a tiny free model or without Group Privacy off — specialists may never see messages,
or the coordinator may invent scheduling instead of @mentioning. Screenshot + note the fix.
