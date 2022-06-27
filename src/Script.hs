module Script
    ( module Project
    , module Turtle
    , module Util
    , module Script
    ) where

import Turtle hiding (nub)
import Prelude hiding (FilePath)
import Util
import Project
import Control.Monad
import Data.List

srcFileDir :: FilePath
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-27-ns-ahmedabad"

-- スクリプト

removeKnownHosts :: IO ()
removeKnownHosts = mapM_ removeKnownHost $ allServers ++ allWorkstations

sshCopyIdAll :: IO ()
sshCopyIdAll = sh $ do
    targetHost <- getOnlyReachables $ allServers ++ allWorkstations
    sshCopyID targetHost

stopAllServersAndWorkstations :: IO ()
stopAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        if targetHost `elem` centralServers
            then do
                echo "Waiting 60s ..."
                endServer targetHost
            else do
                killHascats targetHost
    sh $ do
        targetHost <- getOnlyReachables $ allWorkstations
        killHascats targetHost

updateAllServersAndWorkstations :: IO ()
updateAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        updateHascatsServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        updateHascatsWorkstation targetHost

startAllServersAndWorkstations :: IO ()
startAllServersAndWorkstations = sh $ do
    sh $ do
        targetHost <- getOnlyReachables allServers
        when (targetHost `elem` centralServers) $ echo "Waiting 60s ..."
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        reboot targetHost

-- よく使うIPアドレスのリストの定義

allServers :: [HostName]
allServers = makeHosts 1 [1 .. 14]

centralServers :: [HostName]
centralServers = makeHosts 1 [1,2,3,4]

allWorkstations :: [HostName]
allWorkstations = concat
    [ makeHosts 2 $ concat
        [ [1, 2, 3, 8, 9, 10, 11, 13, 16, 20]
        , [31..35]
        , [37]
        , [40..60]
        , [80..83]
        ]
    , makeHosts 4 $ concat
        [ [1..5]
        , [21, 22]
        ]
    , makeHosts 6 [3]
    ]

-- アップデートコマンド

updateHascatsServer :: MonadIO io => HostName -> io ExitCode
updateHascatsServer targetHost = do
    let srcFilePath = srcFileDir </> serverBinaryName
    let dstFilePath = makeBinaryFilePath serverBinaryName
    scp srcFilePath targetHost dstFilePath

updateHascatsWorkstation :: MonadIO io => HostName -> io ExitCode
updateHascatsWorkstation targetHost = do
    let srcFilePath = srcFileDir </> workstationBinaryName
    let dstFilePath = makeBinaryFilePath workstationBinaryName
    scp srcFilePath targetHost dstFilePath
