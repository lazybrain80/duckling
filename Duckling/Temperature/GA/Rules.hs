-- Copyright (c) 2016-present, Facebook, Inc.
-- All rights reserved.
--
-- This source code is licensed under the BSD-style license found in the
-- LICENSE file in the root directory of this source tree.


{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

module Duckling.Temperature.GA.Rules
  ( rules ) where

import Prelude
import Data.String

import Duckling.Dimensions.Types
import Duckling.Temperature.Helpers
import Duckling.Temperature.Types (TemperatureData (..))
import qualified Duckling.Temperature.Types as TTemperature
import Duckling.Types

ruleLatentTempCim :: Rule
ruleLatentTempCim = Rule
  { name = "<latent temp> céim"
  , pattern =
    [ Predicate $ isValueOnly False
    , regex "g?ch?(é|e)im(e(anna)?)?|°"
    ]
  , prod = \case
      (Token Temperature td:_) -> Just . Token Temperature $
        withUnit TTemperature.Degree td
      _ -> Nothing
  }

ruleTempCelsius :: Rule
ruleTempCelsius = Rule
  { name = "<temp> Celsius"
  , pattern =
    [ Predicate $ isValueOnly True
    , regex "ceinteagr(á|a)d|c(el[cs]?(ius)?)?\\.?"
    ]
  , prod = \case
      (Token Temperature td:_) -> Just . Token Temperature $
        withUnit TTemperature.Celsius td
      _ -> Nothing
  }

ruleTempFahrenheit :: Rule
ruleTempFahrenheit = Rule
  { name = "<temp> Fahrenheit"
  , pattern =
    [ Predicate $ isValueOnly True
    , regex "f(ah?reh?n(h?eit)?)?\\.?"
    ]
  , prod = \case
      (Token Temperature td:_) -> Just . Token Temperature $
        withUnit TTemperature.Fahrenheit td
      _ -> Nothing
  }

ruleLatentTempFaoiBhunNid :: Rule
ruleLatentTempFaoiBhunNid = Rule
  { name = "<latent temp> faoi bhun náid"
  , pattern =
    [ Predicate $ isValueOnly True
    , regex "faoi bhun (0|n(a|á)id)"
    ]
  , prod = \case
      (Token Temperature td@TemperatureData{TTemperature.value = Just v}:_) ->
        case TTemperature.unit td of
          Nothing -> Just . Token Temperature . withUnit TTemperature.Degree $
            td {TTemperature.value = Just (- v)}
          _ -> Just . Token Temperature $ td {TTemperature.value = Just (- v)}
      _ -> Nothing
  }

rules :: [Rule]
rules =
  [ ruleLatentTempCim
  , ruleLatentTempFaoiBhunNid
  , ruleTempCelsius
  , ruleTempFahrenheit
  ]
