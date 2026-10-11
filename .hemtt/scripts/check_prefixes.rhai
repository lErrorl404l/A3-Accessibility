// Verify that every addon folder carries a $PBOPREFIX$ file.
// A missing prefix breaks the virtual path of the addon.
// Plan section 7.6 step 4. DISP pattern, docs/research/08-example-mods.md item 9.
// Run with: hemtt script check_prefixes

let addons = HEMTT_RFS.join("addons").list();
let missing = 0;

for addon in addons {
    if addon.is_dir() {
        if !addon.join("$PBOPREFIX$").exists() {
            print("ERROR: missing $PBOPREFIX$ in addons/" + addon.name());
            missing += 1;
        }
    }
}

if missing > 0 {
    throw "Found " + missing.to_string() + " addon folder(s) without a $PBOPREFIX$";
}

print("All addon folders carry a $PBOPREFIX$.");
