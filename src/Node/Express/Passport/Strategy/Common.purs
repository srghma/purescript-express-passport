module Node.Express.Passport.Strategy.Common where

import Prelude
import Effect (Effect)
import Data.Function.Uncurried (Fn3, runFn3)
import Node.Express.Passport.Types

data PassportStrategy

foreign import _setStrategy ::
  Fn3
    Passport
    String
    PassportStrategy
    (Effect Unit)

setStrategy ::
  Passport ->
  String ->
  PassportStrategy ->
  Effect Unit
setStrategy = runFn3 _setStrategy
