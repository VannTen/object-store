module Main where

import Api
import Storage as O

import Servant
import Network.Wai.Handler.Warp
import Control.Monad.IO.Class
import Data.ByteString
import Data.Functor

server :: Server ObjectStore
server x i = put :<|> get :<|> delete
    where
    object_path =  x <> "/" <> show i

    put object_data = (liftIO . O.store x i) object_data $> NoContent

    get = liftIO $ O.retrieve x i

    delete = liftIO (O.delete x i) $> NoContent

objectApi :: Proxy ObjectStore
objectApi = Proxy

app :: Application
app = serve objectApi server

main :: IO ()
main = run 8080 app
