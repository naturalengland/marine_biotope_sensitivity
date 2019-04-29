distinct_eunis <- sbgr.hab.max.sens.assessed %>%
        group_by(pkey) %>%
        filter(max.sens.consolidate == max(max.sens.consolidate)) %>%
        tidyr::spread(key = PressureCode, value = eunis.match.assessed)

