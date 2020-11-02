module Node.Express.Passport.Types where

import Unsafe.Coerce (unsafeCoerce)

data Passport

-------------------

data UserRaw

-- safety precaution, but it's still unsafe
class IsPassportUser a

unsafeToUserRaw :: forall a . IsPassportUser a => a -> UserRaw
unsafeToUserRaw = unsafeCoerce

unsafeFromUserRaw :: forall a . IsPassportUser a => UserRaw -> a
unsafeFromUserRaw = unsafeCoerce

-------------------

data InfoRaw

class IsPassportInfo a

unsafeToInfoRaw :: forall a . IsPassportInfo a => a -> InfoRaw
unsafeToInfoRaw = unsafeCoerce

unsafeFromInfoRaw :: forall a . IsPassportInfo a => InfoRaw -> a
unsafeFromInfoRaw = unsafeCoerce
