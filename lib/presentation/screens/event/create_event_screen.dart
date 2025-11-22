// screens/create_event/create_event_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:innercircle/blocs/auth/auth_bloc.dart';
import 'package:innercircle/blocs/auth/auth_state.dart';
import 'package:innercircle/blocs/events/events_bloc.dart';
import 'package:innercircle/blocs/events/events_event.dart';
import 'package:innercircle/blocs/events/events_state.dart';
import 'package:innercircle/core/theme/app_colors.dart';
import 'package:innercircle/core/theme/app_dimensions.dart';
import 'package:innercircle/core/theme/app_text_styles.dart';
import 'package:innercircle/data/models/event.dart';
import 'package:innercircle/data/repositries/location_repo.dart';
import 'package:innercircle/presentation/widgets/curved_top_container.dart';

import 'package:innercircle/presentation/widgets/input/custom_text_feild.dart';
import 'package:innercircle/presentation/widgets/primary_button.dart';
import 'package:intl/intl.dart';

import 'dart:ui';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Movies';
  DateTime _selectedDateTime = DateTime.now().add(const Duration(hours: 1));
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;

  late AnimationController _formAnimationController;
  late AnimationController _categoryAnimationController;
  late Animation<double> _formAnimation;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Movies',
      'icon': Icons.movie_rounded,
      'color': AppColors.movieColor,
      'emoji': '🎬',
    },
    {
      'name': 'Sports',
      'icon': Icons.sports_basketball_rounded,
      'color': AppColors.sportsColor,
      'emoji': '⚽',
    },
    {
      'name': 'Food & Dining',
      'icon': Icons.restaurant_rounded,
      'color': AppColors.foodColor,
      'emoji': '🍕',
    },
    {
      'name': 'Study Groups',
      'icon': Icons.school_rounded,
      'color': AppColors.studyColor,
      'emoji': '📚',
    },
    {
      'name': 'Volunteering',
      'icon': Icons.volunteer_activism_rounded,
      'color': AppColors.volunteerColor,
      'emoji': '❤️',
    },
    {
      'name': 'Carpooling',
      'icon': Icons.directions_car_rounded,
      'color': AppColors.carpoolColor,
      'emoji': '🚗',
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag_rounded,
      'color': AppColors.shoppingColor,
      'emoji': '🛍️',
    },
    {
      'name': 'Cultural Events',
      'icon': Icons.celebration_rounded,
      'color': AppColors.culturalColor,
      'emoji': '🎉',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _categoryAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _formAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOut,
    );

    _formAnimationController.forward();
    _categoryAnimationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mapController?.dispose();
    _formAnimationController.dispose();
    _categoryAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    final locationService = LocationService();
    final position = await locationService.getCurrentLocation();

    if (position != null && mounted) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _createEvent() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      _showSnackBar('Please select a location on the map', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final event = Event(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      dateTime: _selectedDateTime,
      lat: _selectedLocation!.latitude,
      lng: _selectedLocation!.longitude,
      hostId: authState.user.uid,
      joinedUsers: [authState.user.uid],
    );

    context.read<EventsBloc>().add(EventCreateRequested(event));
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: AppDimensions.spacingM),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkBackground, // top dark purple/grey
              Color(0xFF2F2F40), // mid shadow tone
              AppColors.darkBackground, // bottom almost-black
            ],
            stops: [0.2, 0.5, 1.0],
          ),
        ),
        child: BlocListener<EventsBloc, EventsState>(
          listener: (context, state) {
            if (state is EventCreated) {
              _showSnackBar('🎉 Event created successfully!');

              // Clear form with animation
              _formAnimationController.reverse().then((_) {
                _titleController.clear();
                _descriptionController.clear();
                setState(() {
                  _selectedCategory = 'Movies';
                  _selectedDateTime = DateTime.now().add(
                    const Duration(hours: 1),
                  );
                });
                _formAnimationController.forward();
              });

              context.read<EventsBloc>().add(EventsLoadRequested());
            } else if (state is EventsError) {
              _showSnackBar(state.message, isError: true);
            }
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: CurvedTopContainer(
                    child: SafeArea(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingL,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Create Event 🎉',
                              style: AppTextStyles.headline.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Bring people together',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Form Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _formAnimation,
                  child: Padding(
                    padding: EdgeInsets.all(AppDimensions.spacingM),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppDimensions.spacingM),

                          // Category Selection
                          _buildSectionTitle('Choose Category', '🎯'),
                          SizedBox(height: 1),
                          _buildCategoryGrid(),
                          SizedBox(height: 1),

                          // Event Details
                          _buildSectionTitle('Event Details', '📝'),
                          SizedBox(height: AppDimensions.spacingM),
                          _buildEventDetailsCard(),
                          SizedBox(height: AppDimensions.spacingXL),

                          // Date & Time
                          _buildSectionTitle('When', '📅'),
                          SizedBox(height: AppDimensions.spacingM),
                          _buildDateTimeCard(),
                          SizedBox(height: AppDimensions.spacingXL),

                          // Location
                          _buildSectionTitle('Where', '📍'),
                          SizedBox(height: AppDimensions.spacingM),
                          _buildLocationCard(),
                          SizedBox(height: AppDimensions.spacingXL),

                          // Create Button
                          BlocBuilder<EventsBloc, EventsState>(
                            builder: (context, state) {
                              final isLoading = state is EventsLoading;
                              return PrimaryButton(
                                text: 'Create Event',
                                onPressed: isLoading ? null : _createEvent,
                                isLoading: isLoading,
                                icon: Icons.rocket_launch_rounded,
                              );
                            },
                          ),
                          SizedBox(height: 150), // Bottom padding for nav
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String emoji) {
    return Row(
      children: [
        Text(emoji, style: TextStyle(fontSize: 24)),
        SizedBox(width: AppDimensions.spacingS),
        Text(
          title,
          style: AppTextStyles.subheading.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final isSelected = category['name'] == _selectedCategory;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (index * 50)),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedCategory = category['name']);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? LinearGradient(
                              colors: [
                                category['color'],
                                category['color'].withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : null,
                    color: isSelected ? null : AppColors.darkSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? AppColors.darkPrimary
                              : AppColors.borderLight,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            isSelected
                                ? category['color'].withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 12 : 6,
                        offset: Offset(0, isSelected ? 6 : 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(category['emoji'], style: TextStyle(fontSize: 32)),
                      SizedBox(height: 4),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.darkText,
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEventDetailsCard() {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomTextField(
              controller: _titleController,
              labelText: 'Event Title',
              hintText: 'e.g., Movie Night at PVR',
              suffixIcon: Icon(
                Icons.title_rounded,
                color: AppColors.darkPrimary,
              ),
              prefixIcon: Icon(Icons.title_rounded, color: AppColors.primary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter event title';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: AppDimensions.spacingM),
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CustomTextField(
              controller: _descriptionController,
              labelText: 'Description',
              hintText: 'Tell others about your event...',
              maxLines: 4,
              suffixIcon: Icon(
                Icons.description_rounded,
                color: AppColors.darkPrimary,
              ),
              prefixIcon: Icon(
                Icons.description_rounded,
                color: AppColors.primary,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return InkWell(
      onTap: _selectDateTime,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spacingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkPrimary.withOpacity(0.1),
              AppColors.darkTextSecondary.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.white.withOpacity(0.9)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppDimensions.spacingM),
              decoration: BoxDecoration(
                color: AppColors.darkPrimary,

                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM dd').format(_selectedDateTime),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('hh:mm a').format(_selectedDateTime),
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              color: AppColors.darkTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            _isLoadingLocation
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'Getting your location...',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
                : _selectedLocation == null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppDimensions.spacingM),
                      Text(
                        'Location not available',
                        style: AppTextStyles.bodyMedium,
                      ),
                      SizedBox(height: AppDimensions.spacingS),
                      TextButton.icon(
                        onPressed: _loadCurrentLocation,
                        icon: Icon(Icons.refresh_rounded),
                        label: Text('Retry'),
                      ),
                    ],
                  ),
                )
                : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _selectedLocation!,
                        zoom: 15,
                      ),
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      onTap: (position) {
                        setState(() => _selectedLocation = position);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('event'),
                          position: _selectedLocation!,
                          draggable: true,
                          onDragEnd: (position) {
                            setState(() => _selectedLocation = position);
                          },
                        ),
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: EdgeInsets.all(AppDimensions.spacingM),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                SizedBox(width: AppDimensions.spacingS),
                                Expanded(
                                  child: Text(
                                    'Tap or drag to set location',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
