module Main where

import Api
import Storage as O

import Servant
import Network.Wai.Handler.Warp
import Control.Monad.IO.Class
import Data.ByteString
import Data.Functor
import Options.Applicative

server :: Server ObjectStore
server x i = put :<|> get :<|> delete
    where
    put object_data = (liftIO . O.store x i) object_data $> Id i

    get = liftIO (O.ifObj x i O.retrieve) >>= found

    delete = (liftIO (O.ifObj x i O.delete) >>= found) $> NoContent

found :: Maybe a -> Servant.Handler a
found res = case res of
        Nothing -> throwError err404
        Just response -> pure response

objectApi :: Proxy ObjectStore
objectApi = Proxy

app :: Application
app = serve objectApi server

port :: Parser Int
port = option auto
                (long "port" <>
                short 'p' <>
                metavar "PORT" <>
                help "Port to bind on" <>
                value 8080)

main :: IO ()
main = do
    port <- execParser (info (port <**> helper) $ header "Simple object storage server")
    run port app
