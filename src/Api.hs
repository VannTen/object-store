{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module Api where

import Servant.API
import Data.ByteString


type ObjectStore = "objects" :> Capture "bucket" String :> Capture "objectID" Int :>
    ( ReqBody '[OctetStream] ByteString :> Put '[PlainText] NoContent
    :<|>                             Get '[OctetStream] ByteString
    :<|> Delete '[PlainText] NoContent
    )
