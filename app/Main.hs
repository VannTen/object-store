module Main where

import Api
import Storage as O

import Servant
import Network.Wai.Handler.Warp
import Control.Monad.IO.Class
import Data.ByteString

server :: Server ObjectStore
server x i = put :<|> get :<|> delete
    where
    object_path =  x <> "/" <> show i

    put object_data = (liftIO . O.store object_path) object_data *> pure NoContent

    get = liftIO . O.retrieve $ object_path

    delete = (liftIO . O.delete) object_path *> pure NoContent

objectApi :: Proxy ObjectStore
objectApi = Proxy

app :: Application
app = serve objectApi server

main :: IO ()
main = run 8080 app
