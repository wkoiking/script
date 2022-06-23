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
srcFileDir = "/mnt/c/Users/wanag/Desktop/bin/2022-06-21-dhaka-bin"

-- スクリプト

sshCopyIdAll :: IO ()
sshCopyIdAll = sh $ do
        targetHost <- getOnlyReachables $ allServers ++ allWorkstations
        removeKnownHost targetHost
        sshCopyID targetHost

stopAllServersAndWorkstations :: IO ()
stopAllServersAndWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        echo "Waiting 60s ..."
        endServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        killHascats targetHost

updateCentralServersAndTargetWorkstations :: IO ()
updateCentralServersAndTargetWorkstations = do
    sh $ do
        targetHost <- getOnlyReachables allServers
        updateHascatsServer targetHost
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        updateHascatsWorkstation targetHost
        reboot targetHost

startAllServersAndWorkstations :: IO ()
startAllServersAndWorkstations = sh $ do
    sh $ do
        targetHost <- getOnlyReachables allServers
        startServer targetHost
    sh $ do
        targetHost <- getOnlyReachables allWorkstations
        reboot targetHost

-- よく使うIPアドレスのリストの定義

allServers :: [HostName]
allServers = makeHosts 1 [1, 2]

allWorkstations :: [HostName]
allWorkstations = concat
    [ makeHosts 2 [1, 2, 3, 4, 5, 6, 7, 8, 9, 41, 32, 33, 34, 35]
    , makeHosts 4 [1..6]
    , makeHosts 6 [1,2]
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
