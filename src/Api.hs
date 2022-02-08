{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE TypeOperators #-}

module Api
  ( Id (..),
    ObjectStore,
  )
where

import Data.Aeson.Types
import Data.ByteString
import GHC.Generics
import Servant.API

data Id = Id {id :: Int} deriving (Generic)

instance ToJSON Id

type ObjectStore =
  "objects" :> Capture "bucket" String :> Capture "objectID" Int
    :> ( ReqBody '[OctetStream] ByteString :> PutCreated '[JSON] Id
           :<|> Get '[OctetStream] ByteString
           :<|> Delete '[PlainText] NoContent
       )
