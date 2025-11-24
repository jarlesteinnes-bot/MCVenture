# Fuel Cost and Consumption Calculations

## Overview
MCVenture now includes comprehensive fuel cost and consumption calculations for route planning, using your specific motorcycle's fuel efficiency and tank size to provide accurate estimates and smart fuel stop recommendations.

## Features

### 1. Fuel Consumption Calculation
**Formula**: `(Fuel Consumption × Distance) ÷ 100`

- **Input**: 
  - Motorcycle's fuel consumption (L/100km) from the motorcycle database
  - Route total distance (km)
  
- **Output**: Total liters of fuel needed for the route

**Example**:
```
Motorcycle: Harley-Davidson Road King (6.1 L/100km)
Route Distance: 450 km
Fuel Needed: (6.1 × 450) ÷ 100 = 27.45 liters
```

### 2. Fuel Cost Calculation
**Formula**: `Fuel Consumption × Fuel Price Per Liter`

- **Input**:
  - Estimated fuel consumption (liters)
  - Fuel price per liter (default: 19.50 NOK for Norway)
  
- **Output**: Total estimated cost for the route

**Example**:
```
Fuel Needed: 27.45 liters
Fuel Price: 19.50 NOK/liter
Total Cost: 27.45 × 19.50 = 535.28 NOK
```

### 3. Smart Fuel Stop Recommendations

#### Using Actual Tank Size
The system now uses your **motorcycle's actual tank size** from the database instead of a generic default:

- **Tank Capacity**: Retrieved from motorcycle model (e.g., Road King = 22.7L)
- **Safety Margin**: 90% of tank capacity used for calculations
- **Usable Range**: `(Tank Size × 0.9) ÷ Fuel Consumption × 100`

**Example**:
```
Motorcycle: BMW R 1250 GS
Tank Size: 20.4 liters
Usable Fuel: 20.4 × 0.9 = 18.36 liters
Fuel Consumption: 5.0 L/100km
Fuel Range: (18.36 ÷ 5.0) × 100 = 367 km
```

#### Fuel Stop Placement
- **Calculation**: Stops suggested every `fuelRange` km
- **Number of Stops**: `ceil(Total Distance ÷ Fuel Range) - 1`
- **Location**: Positioned along route at calculated intervals
- **Display**: Shows "Suggested location at ~XXX km"

**Example**:
```
Route Distance: 800 km
Fuel Range: 367 km
Number of Stops: ceil(800 ÷ 367) - 1 = 2 - 1 = 1 stop

Stop 1: At ~367 km (halfway through fuel range)
```

### 4. Motorcycle Database Integration

All motorcycles in the database include:
- **Brand & Model**: Full motorcycle identification
- **Year**: Model year
- **Fuel Consumption**: Liters per 100 kilometers (L/100km)
- **Tank Size**: Fuel tank capacity in liters
- **Engine Size**: Displacement in CC

**Example Entries**:
```swift
Harley-Davidson Road King (2024): 6.1 L/100km, 22.7L tank
BMW R 1250 GS (2024): 5.0 L/100km, 20.4L tank
Yamaha MT-07 (2024): 3.8 L/100km, 17.3L tank
Honda Grom (2024): 2.1 L/100km, 9.2L tank
Ducati Panigale V4 (2024): 6.8 L/100km, 21.4L tank
```

## Technical Implementation

### Data Models

#### RoutePlan (Extended)
```swift
struct RoutePlan {
    // ... existing properties ...
    
    // Fuel calculations
    var estimatedFuelConsumption: Double = 0  // Liters
    var estimatedFuelCost: Double = 0         // Currency
    var fuelPricePerLiter: Double = 19.50     // Default NOK
}
```

#### Motorcycle
```swift
struct Motorcycle {
    let brand: String
    let model: String
    let year: Int
    let fuelConsumption: Double  // L/100km
    let tankSize: Double          // Liters
    let engineSize: Int           // CC
}
```

### Calculation Flow

1. **User selects motorcycle** → Profile stores selected motorcycle
2. **User plans route** → Adds waypoints, system calculates distance
3. **System calculates fuel needs**:
   ```swift
   let fuelNeeded = (motorcycle.fuelConsumption * route.totalDistance) / 100
   let fuelCost = fuelNeeded * route.fuelPricePerLiter
   ```
4. **System suggests fuel stops**:
   ```swift
   let usableTankSize = motorcycle.tankSize * 0.9
   let fuelRange = usableTankSize / motorcycle.fuelConsumption * 100
   let numberOfStops = Int(ceil(route.totalDistance / fuelRange)) - 1
   ```
5. **Fuel stops positioned** → Placed at intervals along the route

### Code Locations

**RoutePlannerManager.swift**:
- Line 165-170: Fuel consumption and cost calculation
- Line 245-267: Fuel stop suggestion logic

**RoutePlanningModels.swift**:
- Line 155-158: Fuel calculation properties

**Motorcycle.swift**:
- Line 15: `fuelConsumption` property
- Line 17: `tankSize` property
- Lines 27-523: Complete motorcycle database

## User Experience

### Route Planning View
When planning a route, users see:
- **Total fuel needed** (e.g., "27.5 L")
- **Estimated fuel cost** (e.g., "536 NOK")
- **Suggested fuel stops** with distances
- **Fuel range** for their motorcycle

### Guided Mode
Step 4 "Calculate Route" shows:
- Distance, Time, Elevation, Difficulty
- **Fuel consumption and cost** prominently displayed

### Advanced Mode
"Elevation & Analytics" tab includes:
- Fuel Stops section with suggested locations
- Ability to add suggested stops to route
- Visual indication of fuel stop positions

### Fuel Stop Cards
Each suggested fuel stop displays:
- **Icon**: Gas pump (orange)
- **Name**: "Fuel Stop 1", "Fuel Stop 2", etc.
- **Distance**: "Suggested location at ~367 km"
- **Add button**: Quick-add to route waypoints

## Fuel Price Customization

### Default Pricing
- **Norway**: 19.50 NOK/liter (current default)
- Users can modify this per-route if needed

### Future Enhancements
1. **Real-time fuel prices** via API
2. **Currency selection** (NOK, EUR, USD, etc.)
3. **Fuel type** (95 octane, 98 octane, diesel)
4. **Country-specific pricing** based on route location
5. **Fuel station recommendations** with actual prices from nearby stations

## Benefits

### For Route Planning
✓ Know exact fuel costs before you ride
✓ Budget accurately for long trips
✓ Compare route fuel efficiency
✓ Choose economical vs fast routes

### For Safety
✓ Never run out of fuel unexpectedly
✓ Automatic stop recommendations
✓ Safety margin built into calculations
✓ Account for specific motorcycle range

### For Optimization
✓ Use actual motorcycle specifications
✓ Accurate range calculations
✓ Real-world fuel consumption data
✓ 500+ motorcycles in database

## Example Scenarios

### Scenario 1: Long Tour
**Motorcycle**: Harley-Davidson Ultra Limited (6.3 L/100km, 22.7L tank)
**Route**: Oslo to Trondheim (500 km)

**Calculations**:
- Fuel needed: (6.3 × 500) ÷ 100 = 31.5 liters
- Fuel cost: 31.5 × 19.50 = 614.25 NOK
- Fuel range: (22.7 × 0.9) ÷ 6.3 × 100 = 324 km
- Fuel stops needed: ceil(500 ÷ 324) - 1 = 1 stop
- **Stop at**: ~324 km mark

### Scenario 2: Sport Ride
**Motorcycle**: Yamaha YZF-R1 (5.8 L/100km, 17.0L tank)
**Route**: Twisty mountain loop (200 km)

**Calculations**:
- Fuel needed: (5.8 × 200) ÷ 100 = 11.6 liters
- Fuel cost: 11.6 × 19.50 = 226.20 NOK
- Fuel range: (17.0 × 0.9) ÷ 5.8 × 100 = 264 km
- Fuel stops needed: ceil(200 ÷ 264) - 1 = 0 stops
- **No refueling needed** ✓

### Scenario 3: Economical Commute
**Motorcycle**: Honda Grom (2.1 L/100km, 9.2L tank)
**Route**: Daily commute (80 km round trip)

**Calculations**:
- Fuel needed: (2.1 × 80) ÷ 100 = 1.68 liters
- Fuel cost: 1.68 × 19.50 = 32.76 NOK
- Fuel range: (9.2 × 0.9) ÷ 2.1 × 100 = 395 km
- **Can ride 5 days** before refueling

## Accuracy Notes

### Factors Affecting Accuracy
1. **Riding style**: Aggressive riding increases consumption
2. **Weather**: Headwinds increase consumption
3. **Load**: Passenger and luggage affect efficiency
4. **Terrain**: Mountains require more fuel than flat roads
5. **Traffic**: City riding vs highway riding

### Typical Variance
Real-world consumption may vary ±10-15% from calculated values due to:
- Individual riding habits
- Road conditions
- Motorcycle maintenance state
- Tire pressure and type
- Altitude changes

### Safety Margin
The 90% tank capacity safety margin accounts for:
- Reserve fuel warning light
- Finding a gas station
- Detours or changes in route
- Unexpected delays

## Conclusion

MCVenture's fuel calculation system provides accurate, motorcycle-specific estimates for fuel consumption and costs, helping riders:
- **Plan better** - Know costs before you go
- **Ride safer** - Never run out of fuel
- **Budget smarter** - Accurate expense forecasting
- **Choose wisely** - Compare route economics

All calculations use your specific motorcycle's real-world specifications from our comprehensive 500+ bike database!
