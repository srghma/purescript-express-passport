module Node.Express.Passport.Strategy.Local where

import Data.Function.Uncurried
import Effect
import Effect.Uncurried
import Node.Express.Passport.Strategy.Common
import Prelude

import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Nullable (Nullable)
import Data.Nullable as Nullable
import Effect.Exception (Error)
import Node.Express.Types (Request)
import Node.Express.Passport.Types

type PassportStrategyLocalOptions
  = { usernameField :: String
    , passwordField :: String
    }

defaultPassportStrategyLocalOptions :: PassportStrategyLocalOptions
defaultPassportStrategyLocalOptions = { usernameField: "username", passwordField: "password" }

newtype Username
  = Username String

derive instance newtypeUsername :: Newtype Username _

newtype Password
  = Password String

derive instance newtypePassword :: Newtype Password _

type PassportStrategyLocal__Implementation__CredentialsVerified
  = EffectFn3 (Nullable Error) (Nullable UserRaw) (Nullable InfoRaw) Unit

type PassportStrategyLocal__Implementation__Verify
  = EffectFn4 Request Username Password (PassportStrategyLocal__Implementation__CredentialsVerified) Unit

data PassportStrategyLocal__CredentialsVerifiedResult
  = PassportStrategyLocal__CredentialsVerifiedResult__Error Error
  | PassportStrategyLocal__CredentialsVerifiedResult__AuthenticationError
  | PassportStrategyLocal__CredentialsVerifiedResult__Success UserRaw

type PassportStrategyLocal__CredentialsVerified
  = { result :: PassportStrategyLocal__CredentialsVerifiedResult
    , info :: Maybe InfoRaw
    }
    -> Effect Unit

type PassportStrategyLocal__Verify
  = Request -> Username -> Password -> PassportStrategyLocal__CredentialsVerified -> Effect Unit

foreign import _passportStrategyLocal ::
  Fn2
  PassportStrategyLocalOptions
  (PassportStrategyLocal__Implementation__Verify)
  PassportStrategy

passportStrategyLocal ::
  PassportStrategyLocalOptions ->
  PassportStrategyLocal__Verify ->
  PassportStrategy
passportStrategyLocal options verify =
  runFn2
  _passportStrategyLocal
  options
  (mkEffectFn4 \req username password verified ->
    verify
    req
    username
    password
    (\{ result, info } ->
      runEffectFn3
      verified
      ( case result of
             PassportStrategyLocal__CredentialsVerifiedResult__Error error -> Nullable.notNull error
             _ -> Nullable.null
      )
      ( case result of
             PassportStrategyLocal__CredentialsVerifiedResult__Success user -> Nullable.notNull user
             _ -> Nullable.null
      )
      (Nullable.toNullable info)
    )
  )
