cd /home/nitai/projects/clients/payroll-expo
git reset --hard
npx expo prebuild --clean
eas build --platform android --profile preview --local
nautilus .
