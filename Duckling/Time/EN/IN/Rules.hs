-- Copyright (c) 2016-present, Facebook, Inc.
-- All rights reserved.
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree.


{-# LANGUAGE GADTs #-}
{-# LANGUAGE NoRebindableSyntax #-}
{-# LANGUAGE OverloadedStrings #-}

module Duckling.Time.EN.IN.Rules
  ( rules
  ) where

import Data.Maybe
import Prelude

import Duckling.Dimensions.Types
import Duckling.Numeral.Helpers (parseInt)
import Duckling.Regex.Types
import Duckling.Time.Computed
import Duckling.Time.Helpers
import Duckling.Time.Types (TimeData (..))
import Duckling.Types
import qualified Duckling.TimeGrain.Types as TG

ruleDDMM :: Rule
ruleDDMM = Rule
  { name = "dd/mm"
  , pattern =
    [ regex "(3[01]|[12]\\d|0?[1-9])\\s?[/-]\\s?(1[0-2]|0?[1-9])"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (dd:mm:_)):_) -> do
        d <- parseInt dd
        m <- parseInt mm
        tt $ monthDay m d
      _ -> Nothing
  }

ruleDDMMYYYY :: Rule
ruleDDMMYYYY = Rule
  { name = "dd/mm/yyyy"
  , pattern =
    [ regex "(3[01]|[12]\\d|0?[1-9])[-/\\s](1[0-2]|0?[1-9])[-/\\s](\\d{2,4})"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (dd:mm:yy:_)):_) -> do
        y <- parseInt yy
        d <- parseInt dd
        m <- parseInt mm
        tt $ yearMonthDay y m d
      _ -> Nothing
  }

-- Clashes with HHMMSS, hence only 4-digit years
ruleDDMMYYYYDot :: Rule
ruleDDMMYYYYDot = Rule
  { name = "dd.mm.yyyy"
  , pattern =
    [ regex "(3[01]|[12]\\d|0?[1-9])\\.(1[0-2]|0?[1-9])\\.(\\d{4})"
    ]
  , prod = \tokens -> case tokens of
      (Token RegexMatch (GroupMatch (dd:mm:yy:_)):_) -> do
        y <- parseInt yy
        d <- parseInt dd
        m <- parseInt mm
        tt $ yearMonthDay y m d
      _ -> Nothing
  }

rulePeriodicHolidays :: [Rule]
rulePeriodicHolidays = mkRuleHolidays
  -- Fixed dates, year over year
  [ ( "Guru Tegh Bahadur's Martyrdom Day", "guru tegh bahadur'?s martyrdom day"
    , monthDay 11 24 )
  , ( "Independence Day", "independence day", monthDay 8 15 )
  , ( "Labour Day", "labour day", monthDay 5 1 )
  , ( "Mahatma Gandhi Jayanti", "mahatma gandhi jayanti", monthDay 10 2 )
  , ( "Republic Day", "republic day", monthDay 1 26 )
  , ( "Shivaji Jayanti", "shivaji jayanti", monthDay 2 19 )

  -- Fixed day/week/month, year over year
  , ( "Father's Day", "father'?s?'? day", nthDOWOfMonth 3 7 6 )
  , ( "Friendship Day", "friendship day", nthDOWOfMonth 1 7 8 )
  , ( "Mother's Day", "mother'?s?'? day", nthDOWOfMonth 2 7 5 )
  , ( "Thanksgiving Day", "thanks?giving( day)?", nthDOWOfMonth 4 4 11 )
  ]

ruleComputedHolidays :: [Rule]
ruleComputedHolidays = mkRuleHolidays
  [ ( "Hazarat Ali's Birthday", "hazarat ali's birthday"
    , cycleNthAfter False TG.Day 12 rajab )
  ]

rules :: [Rule]
rules =
  [ ruleDDMM
  , ruleDDMMYYYY
  , ruleDDMMYYYYDot
  ]
  ++ ruleComputedHolidays
  ++ rulePeriodicHolidays
