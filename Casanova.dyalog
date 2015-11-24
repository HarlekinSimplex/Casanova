:Namespace Casanova
    ⍝ Define Environment 
    ⎕ML←⎕IO←1

    ⍝ CSV Files to read input data from
    CSV_PATH            ← '/home/pi/Casanova/'
    FLIGHT_SCHEDULE_CSV ← 'FlightSchedule.csv'
    HANDLING_COSTS_CSV  ← 'handlingCosts.csv'
    HANDLING_TIMES_CSV  ← 'handlingTimes.csv'
    HUBS_CSV            ← 'Hubs.csv'

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
    HC_NUMERIC_FIELD_INDEX    ← 3 ⍝ Handling Costs
    HT_NUMERIC_FIELD_INDEX    ← 3 ⍝ Handling Times

    ⍝ Index on leg elements that are to be indicated in the keymaped legs
    FS_ROTATION_FIELD_INDEX   ← 1 2 3   ⍝ D, ORIGIN and DESTINATION

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

    :Class classScheduleData
        :Field Public flightLegs     ←⍬
        :Field Public flightSchedule ←⍬

        ∇ make
          :Implements Constructor
          :Access Public
         
            ⍝ Read Leg CSV File (Remove Header) and convert numeric columns
          flightLegs←##.ReadCSVFile(##.CSV_PATH,##.FLIGHT_SCHEDULE_CSV)1
          flightLegs[;##.FS_NUMERIC_FIELD_INDEX]←⍎¨flightLegs[;##.FS_NUMERIC_FIELD_INDEX]
            ⍝ Key selected leg data by FlightID
          flightSchedule←flightLegs[;##.FS_FLIGHT_ID]{⍺ ⍵}⌸flightLegs[;##.FS_ROTATION_FIELD_INDEX]
        ∇
    :EndClass

    :Class classAirportData
        :Field Public airportLocations ←⍬
        :Field Public hubLocations     ←⍬
        :Field Public handlingCosts    ←⍬
        :Field Public handlingTimes    ←⍬

        ∇ make
          :Implements Constructor
          :Access Public
         
            ⍝ Key Airport Locations from the Leg Data
          airportLocations←{⍺}⌸(##.ScheduleData.flightLegs[;2],##.ScheduleData.flightLegs[;3])
            ⍝ Sort Airport Locations ascending
          airportLocations←{⍵[⍋↑⍵]}airportLocations
         
            ⍝ Read Hub Locations CSV File (Remove Header)
          hubLocations←##.ReadCSVFile(##.CSV_PATH,##.HUBS_CSV)1
            ⍝ Sort Hub Locations ascending
          hubLocations←{⍵[⍋↑⍵]}hubLocations[;1]
         
            ⍝ Read Handling Costs CSV File (Remove Header) and convert numeric columns
          handlingCosts←##.ReadCSVFile(##.CSV_PATH,##.HANDLING_COSTS_CSV)1
          handlingCosts[;##.HC_NUMERIC_FIELD_INDEX]←⍎¨handlingCosts[;##.HC_NUMERIC_FIELD_INDEX]
            ⍝ Key Handling Costs by Airport Location
          handlingCosts←handlingCosts[;1]{⍺ ⍵}⌸handlingCosts[;2 3]
         
            ⍝ Read Handling Times CSV File (Remove Header) and convert numeric columns
          handlingTimes←##.ReadCSVFile(##.CSV_PATH,##.HANDLING_TIMES_CSV)1
          handlingTimes[;##.HT_NUMERIC_FIELD_INDEX]←⍎¨handlingTimes[;##.HT_NUMERIC_FIELD_INDEX]
            ⍝ Key Handling Times by Airport Location
          handlingTimes←handlingTimes[;1]{⍺ ⍵}⌸handlingTimes[;2 3]
        ∇
    :EndClass

    ∇ Init
        ⍝ Instantiate and load Schedule Data container
      ScheduleData←⎕NEW classScheduleData
        ⍝ Instantiate and load Airport Data container
      AirportData←⎕NEW classAirportData
    ∇

:EndNamespace
