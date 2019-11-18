read_biotopes_with_or_without_filter <- function(apply_filter = sbgr_filter) {
        if (apply_filter == TRUE ) {
                source("./functions/sbgr_biotopes_from_db.R")
                tbl_eunis_sbgr <- read.sbgr.db(db.path,drv.path) # this tbl is fed into the match_eunis_to_biotope_fn.R where it filters out invalid combinations of biotope and sbgr:
        } else if (apply_filter == FALSE) {
                source("./functions/sbgr_biotopes_from_db_no_filter.R")
                tbl_eunis_sbgr <- read_fake_offshore_sbgr_db(db.path,drv.path)
        }
        tbl_eunis_sbgr
}
