module Test.Main where

import Effect
import Node.Express.Passport
import Node.Express.Passport.Strategy.Common
import Node.Express.Passport.Strategy.Local
import Prelude

import Data.Argonaut.Decode (decodeJson, JsonDecodeError)
import Data.Argonaut.Encode (encodeJson)
import Data.Either (Either, either)
import Data.Maybe (Maybe(..))
import Effect.Console (log)
import Node.Express.Types (Request)

main :: Effect Unit
main = do
  log "You should add some tests."

---------------------------------

newtype AppUsername = AppUsername String

usernameToAppUsername :: Username -> AppUsername
usernameToAppUsername (Username username) = AppUsername username

appUsernameToString (AppUsername x) = x

instance appUsernameIsUserRawIsUser :: IsPassportUser AppUsername

---------------------------------

passportSerializeString :: AddSerializeUser__Callback
passportSerializeString req user = pure $ SerializedUser__Result $ Just $ encodeJson (appUsernameToString appUsername)
  where
        appUsername :: AppUsername
        appUsername = unsafeFromUserRaw user

passportDeserializeString :: AddDeserializeUser__Callback
passportDeserializeString req json = pure $ either onError onSuccess $ (decodeJson json :: Either JsonDecodeError String)
  where
  onError = const DeserializedUser__Pass
  onSuccess = DeserializedUser__Result <<< Just <<< unsafeToUserRaw <<< AppUsername

verify ::
  forall info.
  Request ->
  Username ->
  Password ->
  PassportStrategyLocal__CredentialsVerified ->
  Effect Unit
verify req username password verified =
  verified { result: PassportStrategyLocal__CredentialsVerifiedResult__Success (unsafeToUserRaw $ usernameToAppUsername username), info: Nothing }

initPassport :: Effect Passport
initPassport = do
  passport <- getPassport
  setStrategy passport "local" $ passportStrategyLocal defaultPassportStrategyLocalOptions $ verify
  addDeserializeUser passport passportDeserializeString
  addSerializeUser passport passportSerializeString
  -- TODO: This line should cause type error when uncommented
  -- addSerializeUser passport passportSerializeSomethingElse
  pure passport
