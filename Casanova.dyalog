:Namespace Casanova

    ⍝ CSV Files to read input data from
    CSV_PATH            ← '/home/pi/Casanova/'
    FLIGHT_SCHEDULE_CSV ← 'FlightSchedule.csv'
    HANDLING_COSTS_CSV  ← 'handlingCosts.csv'
    HANDLING_TIMES_CSV  ← 'handlingTimes.csv'
    HUBS_CSV            ← 'Hubs.csv'

    ⍝ Define index constants to access data elements
    ⍝
    ⍝ Flight Schedule
    Legs                      ← ⍬   ⍝ Local variable to hold Legs
    FlightSchedule            ← ⍬   ⍝ Local variable to hold FlightSchedule
    ⍝ Data Element indicies
    FS_ID                     ← 1   ⍝ numeric
    FS_ORIGIN                 ← 2   ⍝ string[3]
    FS_DESTINATION            ← 3   ⍝ string[3]
    FS_DEPARTURE_TIME         ← 4   ⍝ numeric     n days
    FS_ARRIVAL_TIME           ← 5   ⍝ numeric     n days
    FS_FLIGHT_ID              ← 6   ⍝ numeric
    FS_POSITION_IN_FLIGHT     ← 7   ⍝ numeric
    FS_ROTATION_ID            ← 8   ⍝ numeric
    FS_TRANSPORTATION_TYPE    ← 9   ⍝ char        External (E), RFS (F) or Cargo (C)
    FS_AIRCRAFT_TYPE          ← 10  ⍝ string[3]
    FS_VARIABLE_COSTS         ← 11  ⍝ float
    FS_FIXED_COSTS            ← 12  ⍝ float
    FS_CAPACITY               ← 13  ⍝ numeric     n kg
    FS_REALIZATION            ← 14  ⍝ string[10]  'optional' or 'obligatory'
    ⍝ Index on leg element that need string to numeric conversion
    FS_NUMERIC_FIELD_INDEX    ← 1 4 5 6 7 8 11 12 13
    ⍝ Index on leg elements that are to be indicated in the keymaped legs
    FS_ROTATION_FIELD_INDEX   ← 1 2 3   ⍝ Indicate ID, ORIGIN and DESTINATION

    HandlingCosts             ← ⍬   ⍝ Local variable to hold Handling Costs
    HC_NUMERIC_FIELD_INDEX    ← 3

    HandlingTimes             ← ⍬   ⍝ Local variable to hold Handling Times
    HT_NUMERIC_FIELD_INDEX    ← 3

    Hubs                      ← ⍬   ⍝ Local variable to hold Hub Data

    Airports                  ← ⍬   ⍝ Arports with 1:Locations and 2:Hubs

    ⍝ Define Cut utiliy
    ⍝ 
    ⍝ f← ⍺ Cut ⍵
    ⍝ ⍺: Delimiter sequence  '::'
    ⍝ ⍵: String to cut       'aaa::bbb::ccc'
    ⍝ f: Array of strings    'aaa' 'bbb' 'ccc'
    Cut←{⎕ML←3 ⋄ (~⍵∊⍺)⊂⍵}

    ⍝ Load and parse CSV file
    ⍝
    ⍝ file:     Full path of colon separated text file
    ⍝ headline: 1:Remove headline 0:no headline remove 
    ⍝ r:        Table of element strings
    ∇ r←ReadCSVFile(file headline);tie;file;lines
        ⍝ Read file by chunks of 1000 chars
      tie←file ⎕NTIE 0
      file←{r←⎕NREAD ⍵ 80 1000 ⋄ 0=⍴r:r ⋄ r,∇ ⍵}tie
     
        ⍝ Partition file string into an array of strings
        ⍝ by '⎕UCS 13 10' (CR/LF) and removed headline
      lines←headline↓(⎕UCS 13 10)Cut file
     
        ⍝ Partition each line into its elements by ';'
        ⍝ and increase rank (nested vector -> table)
        ⍝ Result is a table of parsed line element strings
      r←↑';'Cut¨lines
    ∇

    ⍝ Build flight rotations from leg element array
    ⍝
    ⍝ r: Array of rotataion flights with all its dentified legs attached
    ∇ r←BuildFlightSchedule;elements;legs
        ⍝ Load and parse SSIM file
      legs←ReadCSVFile(CSV_PATH,FLIGHT_SCHEDULE_CSV)1
     
        ⍝ Convert certain string columns to numeric values
      legs[;FS_NUMERIC_FIELD_INDEX]←⍎¨legs[;FS_NUMERIC_FIELD_INDEX]
      Legs←legs
     
        ⍝ Keymap legs intto rotations by FlightID (like SELECT legs GROUP by FlightID)
      r←legs[;FS_FLIGHT_ID]{⍺ ⍵}⌸↓legs[;FS_ROTATION_FIELD_INDEX]    ⍝ Legs are indicated as vector
⍝        r←legs[;FS_FLIGHT_ID]{⍺ ⍵}⌸legs[;FS_ROTATION_FIELD_INDEX]     ⍝ Legs are indicated as table
    ∇

    ∇ RunAll
      Legs←ReadCSVFile(CSV_PATH,FLIGHT_SCHEDULE_CSV)1
      Legs[;FS_NUMERIC_FIELD_INDEX]←⍎¨Legs[;FS_NUMERIC_FIELD_INDEX]
     
      FlightSchedule←Legs[;FS_FLIGHT_ID]{⍺ ⍵}⌸↓Legs[;FS_ROTATION_FIELD_INDEX]
     
      Hubs←ReadCSVFile(CSV_PATH,HUBS_CSV)1
     
      Airports←2 1⍴(⊂1⌷[2]{⍺,≢⍵}⌸(Legs[;2],Legs[;3]))(⊂1⌷[2]Hubs)
     
      HandlingCosts←ReadCSVFile(CSV_PATH,HANDLING_COSTS_CSV)1
      HandlingCosts[;HC_NUMERIC_FIELD_INDEX]←⍎¨HandlingCosts[;HC_NUMERIC_FIELD_INDEX]
     
      HandlingTimes←ReadCSVFile(CSV_PATH,HANDLING_TIMES_CSV)1
      HandlingTimes[;HT_NUMERIC_FIELD_INDEX]←⍎¨HandlingTimes[;HT_NUMERIC_FIELD_INDEX]
    ∇
:EndNamespace
