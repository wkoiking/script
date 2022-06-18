module Util where

import Turtle
import qualified Data.Text as T
import Prelude hiding (FilePath)
import Project

type HostName = Text

quote :: Text -> Text
quote x = mconcat ["\"", x, "\""]

permission :: Text
permission = "755"

cmd :: MonadIO io => Text -> io ExitCode
cmd str = shell str empty

tshow :: Show a => a -> Text
tshow = T.pack . show

sshCmd' :: MonadIO io => HostName -> Text -> Shell Line -> io ExitCode
sshCmd' targetHost cmdStr stdin = shell (format ("ssh "%s%" "%s) targetHost (quote cmdStr)) stdin

sshCmd :: MonadIO io => HostName -> Text -> io ExitCode
sshCmd targetHost cmdStr = sshCmd' targetHost cmdStr mempty

scp :: MonadIO io => FilePath -> HostName -> FilePath -> io ExitCode
scp srcFilePath targetHost dstFilePath
    = cmd $ format ("scp -p "%fp%" "%s%":"%fp) srcFilePath targetHost dstFilePath

reboot :: MonadIO io => HostName -> io ExitCode
reboot targetHost = sshCmd targetHost cmdStr
 where cmdStr = format ("echo "%s%" | sudo -S reboot &>/dev/null") password

killHascats :: MonadIO io => HostName -> io ExitCode
killHascats targetHost = do
    printf "Killing hascats-exe\n"
    sshCmd targetHost "pkill hascats-exe"

endServer :: MonadIO io => HostName -> io ExitCode
endServer targetHost = sshCmd targetHost "bash ./VDU/EndServer.sh"

startServer :: MonadIO io => HostName -> io ExitCode
startServer targetHost = sshCmd' targetHost "bash ./VDU/StartServer.sh &>/dev/null" ""

makeHosts :: Int -> [Int] -> [HostName]
makeHosts thirdOct ns = map makeHost ns
 where makeHost n = format (s%"@172.21."%w%"."%d) user (100 + thirdOct) n

chmodRemote :: MonadIO io => HostName -> FilePath -> Text -> io ExitCode
chmodRemote targetHost dstFilePath permission = sshCmd targetHost cmdStr
 where cmdStr = format ("chmod "%s%" "%fp) permission dstFilePath

makeBinaryFilePath :: FilePath -> FilePath
makeBinaryFilePath binaryName = "/home" </> user' </> ".local/bin" </> binaryName
 where user' = fromString $ T.unpack user

removeKnownHost :: MonadIO io => HostName -> io ExitCode
removeKnownHost host = cmd $ format ("ssh-keygen -f "%s%" -R "%s) knowHostsPath ipAddr
 where knowHostsPath = quote "/home/nao/.ssh/known_hosts"
       ipAddr = quote $ fromHostToIP host

sshCopyID :: MonadIO io => HostName -> io ExitCode
sshCopyID host = shell (format ("ssh-copy-id "%s) host) mempty

fromHostToIP :: HostName -> Text
fromHostToIP host
    | user <> "@" == hostStr = ipAddr
    | otherwise = host
 where (hostStr, ipAddr) = T.splitAt (T.length user + 1) host

ping :: MonadIO io => HostName -> io (HostName, ExitCode)
ping host = do
    (code, _) <- shellStrict (format ("ping -w 3 "%s) $ fromHostToIP host) mempty
    return (host, code)

getOnlyReachables :: [HostName] -> Shell HostName
getOnlyReachables hosts = do
    awaits <- mapM (fork . ping) hosts
    await <- select awaits
    (host, code) <- wait await
    case code of
        ExitSuccess -> do
            printf ("Processing "%s%"\n") host
            return host
        ExitFailure _ -> do
            printf (s%" is not reachable\n") host
            mempty

areReachable :: [HostName] -> Shell ()
areReachable hosts = do
    awaits <- mapM fork $ map ping hosts
    await <- select awaits
    (host, code) <- wait await
    let ipAddr = fromHostToIP host
    case code of
        ExitSuccess -> printf (s%": success\n") ipAddr
        ExitFailure _ -> printf (s%": failure\n") ipAddr
