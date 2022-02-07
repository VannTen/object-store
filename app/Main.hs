module Main where

import Api
import Storage as O

import Servant
import Network.Wai.Handler.Warp
import Control.Monad.IO.Class
import Control.Exception
import Data.ByteString
import Data.Functor

server :: Server ObjectStore
server x i = put :<|> get :<|> delete
    where
    put object_data = (liftIO . O.store x i) object_data $> NoContent

    get = liftIO (O.ifObj x i O.retrieve) >>= found

    delete = (liftIO (O.ifObj x i O.delete) >>= found) $> NoContent

found :: Maybe a -> Servant.Handler a
found res = case res of
        Nothing -> throw err404
        Just response -> pure response

objectApi :: Proxy ObjectStore
objectApi = Proxy

app :: Application
app = serve objectApi server

main :: IO ()
main = run 8080 app
